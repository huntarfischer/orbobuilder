import SwiftUI
import OrboCore
import OrboIris

@main
struct OrboApp: App {
    @StateObject private var model = OrboApplicationModel()

    var body: some Scene {
        WindowGroup {
            OrboRuntimeView(model: model).task { await model.mount() }
        }
    }
}

@MainActor
private final class OrboApplicationModel: ObservableObject {
    @Published var runtime: OrboSpineRuntime?
    @Published var session: IrisHoraeControlSession?
    @Published var failure: String?
    @Published var working = false
    @Published var orbo = Orbo()
    @Published var hestia: Hestia?
    @Published var hermes = HermesCourier()
    @Published var noticeTicket: HermesTicketID?
    @Published var chronology = ""
    @Published var linkedCoordinates: [OrboSpineCelestialCoordinate] = []
    @Published var linkedFortune: CelestialLongitude?
    @Published var aegis: ApolloAegis?
    @Published var lunarPane: IrisLunarPaneFrame?
    @Published var isLive = true
    @Published var playing = false
    @Published var heldBody: AstroDNAGene?
    @Published var horizonFrame = true
    @Published var aspects = ApolloAspectSettings()
    @Published var tabulaVisible = false
    @Published var tabulaSeat: HermesTabulaSeat = .natal
    @Published var almanacBody: MundaneBody?
    @Published var almanacStreams: Set<ChronosAlmanacStream> = [.stations]
    @Published var keptCourses: Set<LunarCourse> = [] {
        didSet { UserDefaults.standard.set(keptCourses.map(\.rawValue).sorted(), forKey: activeHearthKey + ".lenses") }
    }
    @Published var timingBody: MundaneBody = .moon
    @Published var lunarEvents = false
    @Published var keptHouses: [Hestia] = []
    @Published var keeperMessage = ""
    @Published var playSpeed = 6.0
    private var scrub: ApolloScrub?
    private var pendingScrub: (Double, Double)?
    private var returnStart: (moment: Double, elapsed: Double)?
    private var liveElapsed = 0.0
    @Published var showStars = true
    var environment: AetherEnvironment {
        let source = Aether.astrolabeEnvironment
        return Aether.establishEnvironment(celestialField: source.celestialField,
            starField: showStars ? source.starField : [], earthwardField: source.earthwardField)
    }
    private(set) var horae: Horae?
    private var started = false
    @Published private(set) var startupMeasurements: [String] = []

    private func measure(_ stage: String, since start: TimeInterval) {
        let line = String(format: "%@: %.3f s", stage, ProcessInfo.processInfo.systemUptime - start)
        startupMeasurements.append(line)
        FileHandle.standardOutput.write(Data("ORBO_TIMING \(line)\n".utf8))
    }

    var frame: IrisHoraeFrame? { session?.frame }
    var orboPOV: IrisHomerFrame<OrboLifecycleSnapshot> {
        IrisHomerFrame(port: Homer.POV(orbo.signalForHomer()))
    }
    var journeyPOV: IrisHomerFrame<HermesJourneyPOV>? {
        guard let ticket = orbo.engravingTicketID,
              let signal = hermes.signalForHomer(ticketID: ticket) else { return nil }
        return IrisHomerFrame(port: Homer.POV(signal))
    }
    var hecatePOV: IrisHomerFrame<HecateKleisInquiry>? {
        guard let inquiry = Hecate.inquire(AscendantKleis.id) else { return nil }
        return IrisHomerFrame(port: Homer.POV(Hecate.signalForHomer(inquiry)))
    }

    func mount() async {
        guard !started else { return }
        started = true
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }
        guard let root = Bundle.main.url(forResource: "orbospine-build", withExtension: nil) else {
            failure = "The OrboSpine files are missing from this app."
            return
        }
        do {
            let mountStart = ProcessInfo.processInfo.systemUptime
            let mounted = try await Task.detached(priority: .userInitiated) {
                try OrboSpineRuntime.load(from: root)
            }.value
            measure("Spine load and assembly", since: mountStart)
            let firstFrameStart = ProcessInfo.processInfo.systemUptime
            let horae = Horae(locate: mounted.locate)
            self.runtime = mounted
            self.horae = horae
            self.session = try IrisHoraeControlSession(live: horae)
            try restoreHearths()
            try refreshInstrument()
            measure("First sky presentation", since: firstFrameStart)
            if CommandLine.arguments.contains("--orbo-birth-proof") || CommandLine.arguments.contains("--orbo-instrument-proof") || CommandLine.arguments.contains("--orbo-ui-proof") {
                await submit(name: "Ean Weslynn", date: "1985-04-10", time: "20:16", location: "Madison, WI")
            }
            if CommandLine.arguments.contains("--orbo-ui-proof") {
                isLive = false
                try session?.seek(to: JulianDay(2461286.772071759)!, through: horae)
                try refreshInstrument()
            }
            FileHandle.standardOutput.write(Data("ORBO_READY: real Spine mounted\n".utf8))
            if CommandLine.arguments.contains("--orbo-instrument-proof") { await proveInstrument() }
        } catch { failure = String(describing: error) }
    }

    private func refreshInstrument(natalChanged: Bool = false) throws {
        guard let frame else { return }
        let next: ApolloAegis
        if let aegis, !natalChanged {
            next = try Apollo.advanceAegis(aegis, from: frame.output)
        } else {
            next = try Apollo.establishAegis(from: frame.output, hestia: hestia,
                atPlace: hestia?.nativeEngraving()?.topos)
        }
        aegis = next
        if let reading = lunarPane?.signal.reading {
            selectReading(reading.chart.kind, gene: reading.selectedGene)
        } else if let course = lunarPane?.signal.course?.ticket.subject.course {
            selectCourse(course)
        }
    }

    func selectReading(_ kind: AstrolabeChart.Kind, gene: AstroDNAGene?) {
        guard let aegis else { return }
        guard let chart = kind == .natal ? aegis.natal : aegis.sky else { lunarPane = nil; return }
        do {
            let reading = try Apollo.presentToArtemis(chart, selecting: gene)
            lunarPane = IrisLunarPaneFrame(port: Artemis.signalForIris(reading))
        } catch { failure = String(describing: error) }
    }

    func updateLive() {
        guard isLive, !working, let horae, var session else { return }
        do {
            try session.goLive(through: horae)
            self.session = session
            try refreshInstrument()
        } catch { failure = String(describing: error) }
    }

    func goLive() {
        guard let frame else { return }
        playing = false; scrub = nil; pendingScrub = nil
        returnStart = (frame.julianDay.value, 0)
    }

    func tick(seconds: Double) {
        guard !working else { return }
        let dt = min(0.1, max(0, seconds))
        if let pending = pendingScrub {
            pendingScrub = nil
            applyScrub(angle: pending.0, radius: pending.1)
        } else if var returning = returnStart {
            returning.elapsed += dt
            let now = Date().timeIntervalSince1970 / 86400 + 2440587.5
            let t = min(1, returning.elapsed / 0.65)
            let eased = t * t * (3 - 2 * t)
            seek(JulianDay(returning.moment + (now - returning.moment) * eased)!)
            if t == 1 { returnStart = nil; isLive = true; updateLive() }
            else { returnStart = returning }
        } else if playing, let frame {
            let days = dt * playSpeed / (horizonFrame ? 1440 : 24)
            seek(JulianDay(frame.julianDay.value + days)!)
        } else if isLive {
            liveElapsed += dt
            if liveElapsed >= 1 { liveElapsed = 0; updateLive() }
        }
    }

    func togglePlayback() { returnStart = nil; playing.toggle(); isLive = false }

    func beginScrub(_ gene: AstroDNAGene, angle: Double, radius: Double) {
        guard let frame else { return }
        returnStart = nil; playing = false; isLive = false
        scrub = ApolloScrub(body: gene, julianDay: frame.julianDay, angle: angle, radius: radius)
        heldBody = gene
    }
    func moveScrub(angle: Double, radius: Double) { pendingScrub = (angle, radius) }
    func endScrub() {
        if let pendingScrub { applyScrub(angle: pendingScrub.0, radius: pendingScrub.1) }
        pendingScrub = nil; scrub = nil; heldBody = nil
    }
    private func applyScrub(angle: Double, radius: Double) {
        guard let horae, let aegis, var gesture = scrub else { return }
        let raw = gesture.move(angle: angle, radius: radius, domain: horae.controlDomain)
        scrub = gesture
        do {
            var requested = raw
            if aspects.magnetism > 0 {
                let first = try Apollo.advanceAegis(aegis, from: horae.seek(to: raw))
                let probe = Apollo.bounded(raw.value + min(0.05, Apollo.period(for: gesture.body) / 2000), to: horae.controlDomain)
                if probe.value > raw.value {
                    let second = try Apollo.advanceAegis(aegis, from: horae.seek(to: probe))
                    requested = Apollo.magneticMoment(raw: raw, body: gesture.body, first: first, second: second,
                        settings: aspects, domain: horae.controlDomain)
                }
            }
            seek(requested)
        } catch { failure = String(describing: error); playing = false }
    }

    func seek(_ moment: JulianDay) {
        guard let horae, var session else { return }
        do {
            let bounded = Apollo.bounded(moment.value, to: horae.controlDomain)
            if bounded != moment { playing = false }
            try session.seek(to: bounded, through: horae)
            self.session = session; isLive = false
            try refreshInstrument()
        } catch { failure = String(describing: error); playing = false }
    }

    func jumpTo(_ moment: JulianDay) {
        returnStart = nil; playing = false
        endScrub()
        seek(moment)
    }

    func selectCourse(_ course: LunarCourse) {
        guard let aegis, let horae, let runtime else { return }
        do {
            let reading: ArtemisLunarReading
            switch course {
            case .natal: selectReading(.natal, gene: nil); return
            case .sky: selectReading(.sky, gene: nil); return
            case .relations: reading = try Artemis.relations(aegis.sky, settings: aspects)
            case .moon:
                reading = lunarEvents
                    ? try Artemis.lunarEvents(aegis.sky, using: horae, library: runtime.library)
                    : try Artemis.moon(aegis)
            case .almanac:
                reading = try Artemis.almanac(Chronos.almanacEvents(after: aegis.source.julianDay,
                    body: almanacBody, streams: almanacStreams, using: runtime.library), chart: aegis.sky, body: almanacBody)
            case .timing:
                guard let coordinate = aegis.source.celestial.first(where: { $0.body == timingBody }) else { return }
                let answer = try Pythia.returns(body: timingBody, at: coordinate.directionalDegree, after: aegis.source.julianDay, using: horae)
                reading = try Artemis.chronology(answer, chart: aegis.sky, course: .timing)
            }
            lunarPane = IrisLunarPaneFrame(port: Artemis.signalForIris(reading))
        } catch { lunarPane = nil; failure = "Reading refused: \(error)" }
    }

    private var keeperDirectory: URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let proof = CommandLine.arguments.contains { $0.hasPrefix("--orbo-") }
        return root.appendingPathComponent(proof ? "Hestia-Proof" : "Hestia", isDirectory: true)
    }
    private var activeHearthKey: String { keeperDirectory.lastPathComponent + ".active" }
    private func restoreHearths() throws {
        keptCourses = Set((UserDefaults.standard.stringArray(forKey: activeHearthKey + ".lenses") ?? []).compactMap(LunarCourse.init(rawValue:)))
        try FileManager.default.createDirectory(at: keeperDirectory, withIntermediateDirectories: true)
        keptHouses = try FileManager.default.contentsOfDirectory(at: keeperDirectory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }.map { try HestiaPersistence.load(from: $0) }
        if !CommandLine.arguments.contains(where: { $0.hasPrefix("--orbo-") }),
           let active = UserDefaults.standard.string(forKey: activeHearthKey) {
            hestia = keptHouses.first { $0.nativeSubjectID.rawValue == active }
        }
    }
    func keepHearth() {
        guard let hestia, hestia.hearthLit else { return }
        do {
            try HestiaPersistence.save(hestia, to: keeperDirectory.appendingPathComponent(hestia.nativeSubjectID.rawValue + ".json"))
            UserDefaults.standard.set(hestia.nativeSubjectID.rawValue, forKey: activeHearthKey)
            if let index = keptHouses.firstIndex(where: { $0.nativeSubjectID == hestia.nativeSubjectID }) { keptHouses[index] = hestia }
            else { keptHouses.append(hestia) }
            keeperMessage = "Kept by Hestia"
        } catch { failure = "Hestia could not save: \(error)" }
    }
    func restore(_ house: Hestia) {
        hestia = house
        UserDefaults.standard.set(house.nativeSubjectID.rawValue, forKey: activeHearthKey)
        do { try refreshInstrument(natalChanged: true); selectReading(.natal, gene: nil); tabulaVisible = false }
        catch { failure = String(describing: error) }
    }

    /// Simulator acceptance drives the same selection path used by the controls.
    /// Every frame is read from the bundled sealed Spine; no fixture sky is mounted.
    private func proveInstrument() async {
        guard let horae, let date = ISO8601DateFormatter().date(from: "2026-09-03T06:31:47Z") else { return }
        do {
            isLive = false
            session = try IrisHoraeControlSession(horae: horae,
                initialJulianDay: JulianDay(date.timeIntervalSince1970 / 86400 + 2440587.5)!)
            lunarPane = nil
            try refreshInstrument()
            FileHandle.standardOutput.write(Data("ORBO_AEGIS_READY\n".utf8))
            try await Task.sleep(for: .seconds(15))
            selectReading(.natal, gene: nil)
            FileHandle.standardOutput.write(Data("ORBO_PANE_READY\n".utf8))
            try await Task.sleep(for: .seconds(15))
            selectReading(.natal, gene: .sun)
            FileHandle.standardOutput.write(Data("ORBO_PLACEMENT_READY\n".utf8))
            try await Task.sleep(for: .seconds(15))
            lunarPane = nil
            goLive()
            let firstLiveMoment = frame?.julianDay
            let keptNatal = aegis?.natal
            try await Task.sleep(for: .seconds(4))
            guard let firstLiveMoment, let nextLiveMoment = frame?.julianDay,
                  nextLiveMoment.value > firstLiveMoment.value,
                  aegis?.natal == keptNatal else {
                throw NSError(domain: "OrboInstrumentProof", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "The live frame must advance while the natal chart stays unchanged."])
            }
            FileHandle.standardOutput.write(Data("ORBO_LIVE_READY: \(firstLiveMoment.value) -> \(nextLiveMoment.value)\n".utf8))
        } catch {
            failure = String(describing: error)
            FileHandle.standardOutput.write(Data("ORBO_PROOF_FAILED: \(error)\n".utf8))
        }
    }

    func shift(days: Double) {
        guard let horae, var session else { return }
        returnStart = nil; playing = false
        do {
            try session.shift(by: HoraeUTOffset(days: days)!, through: horae)
            self.session = session
            isLive = false
            try refreshInstrument()
            linkedCoordinates = []
            linkedFortune = nil
            chronology = ""
            failure = nil
        } catch { failure = String(describing: error) }
    }

    func submit(name: String, date: String, time: String, location: String) async {
        guard let horae, !working else { return }
        let d = date.split(separator: "-", omittingEmptySubsequences: false)
        let t = time.split(separator: ":", omittingEmptySubsequences: false)
        guard d.count == 3, t.count == 2,
              let year = Int(d[0]), let month = Int(d[1]), let day = Int(d[2]),
              let hour = Int(t[0]), let minute = Int(t[1]),
              let birthDate = CivilDate(year: year, month: month, day: day),
              let birthTime = CivilClockTime(hour: hour, minute: minute) else {
            failure = "Enter a date as YYYY-MM-DD and local birth time as HH:MM (24-hour)."
            return
        }
        working = true
        failure = nil
        chronology = ""
        linkedCoordinates = []
        linkedFortune = nil
        defer { working = false }
        let engravingStart = ProcessInfo.processInfo.systemUptime
        let result = await Task.detached(priority: .userInitiated) {
            var orbo = Orbo()
            var hermes = HermesCourier()
            var hestia = Hestia(nativeSubjectID: HermesSubjectID(rawValue: UUID().uuidString)!)
            var horae = horae
            var notice: HermesTicketID?
            var failure: String?
            do {
                _ = orbo.beginOnboarding()
                _ = try orbo.respondToOnboarding(.name(name))
                _ = try orbo.respondToOnboarding(.astrologyInterest(.interested))
                _ = try orbo.respondToOnboarding(.birthDate(birthDate))
                _ = try orbo.respondToOnboarding(.birthLocation(location))
                _ = try orbo.respondToOnboarding(.birthTimeKnowledge(.known))
                _ = try orbo.respondToOnboarding(.birthTime(birthTime))
                notice = try deliverOrboEngraving(orbo: &orbo, horae: &horae, hermes: &hermes, hestia: &hestia)
            } catch let error as OrboEngravingDeliveryFailure {
                switch error {
                case let .atlasUnresolved(resolution):
                    switch resolution {
                    case let .ambiguous(places):
                        failure = "Choose a more specific place: " + places.prefix(8).map { $0.place.canonicalName }.joined(separator: "; ")
                    case .notFound: failure = "Atlas could not find that place. Enter a city and region."
                    case .ambiguousTempus: failure = "That local time occurred twice during a clock change. This input needs disambiguation."
                    case .nonexistentCivilTime: failure = "That local time did not exist during a clock change. Check the birth time."
                    default: failure = "Atlas cannot resolve this birth input: \(resolution)"
                    }
                }
            } catch { failure = String(describing: error) }
            return (orbo, hermes, hestia, notice, failure)
        }.value
        measure("Birth engraving and Hearth delivery", since: engravingStart)
        guard result.4 == nil else { failure = result.4; return }
        orbo = result.0
        hermes = result.1
        hestia = result.2
        noticeTicket = result.3
        failure = result.4
        if let birth = hestia?.nativeEngraving(), let tempus = birth.tempus, let dna = birth.astroDNA {
            do {
                session = isLive ? try IrisHoraeControlSession(live: horae)
                    : try IrisHoraeControlSession(horae: horae, initialJulianDay: tempus.absoluteInstant.julianDay)
                try refreshInstrument(natalChanged: true)
                keepHearth()
                _ = try orbo.advanceAstrosphereIntroduction()
                let truth = OrboEstablishedBigThree(
                    ascendantSign: String(describing: dna.longitude(of: .ascendant).sign).capitalized,
                    moonSign: String(describing: dna.longitude(of: .moon).sign).capitalized,
                    sunSign: String(describing: dna.longitude(of: .sun).sign).capitalized
                )!
                _ = try orbo.beginBigThree(with: truth)
                FileHandle.standardOutput.write(Data("ORBO_HEARTH_LIT: \(birth.name); \(truth.ascendantSign) / \(truth.moonSign) / \(truth.sunSign)\n".utf8))
            } catch { failure = String(describing: error) }
        }
        if result.4 != nil { try? refreshInstrument(natalChanged: true) }
    }

    func advanceIntroduction() {
        guard let progress = orbo.bigThreeSession?.progress else { return }
        do {
            if progress == .tourChoice { _ = try orbo.respondToBigThreeTour(.noThanks) }
            else if progress != .complete { _ = try orbo.advanceBigThree() }
        } catch { failure = String(describing: error) }
    }

    func queryChronos(body: MundaneBody, occurrences: Bool) {
        guard let runtime, let horae, let frame else { return }
        do {
            let resolution: ChronosResolution
            let predicate: ChronosPredicate
            if occurrences, let coordinate = frame.output.celestial.first(where: { $0.body == body }) {
                resolution = try Chronos.resolveBodyState(body: body, directionalDegree: coordinate.directionalDegree, using: horae)
                predicate = .bodyState(body: body, directionalDegree: coordinate.directionalDegree)
            } else {
                resolution = Chronos.resolveStations(body: body, using: runtime.library)
                predicate = .station(body: body)
            }
            let query = ChronosQuery(predicate: predicate, relation: .after, anchor: frame.julianDay, limit: 20)!
            if case let .resolved(answer) = Chronos.apply(query, to: resolution),
               case let .text(text) = Chronos.express(answer, as: ChronosExpressionRequest(format: .txt)!) {
                chronology = text
            }
        } catch { failure = String(describing: error) }
    }

    func askHecate() {
        guard let runtime, let frame else { return }
        do {
            let addresses = try frame.output.celestial.map { try runtime.link.address(of: $0) }
            let request = HecateLink(link: SpineLinkSet(members: addresses)!)
            linkedCoordinates = try request.coordinates(through: runtime.link)
            linkedFortune = nil
            // Cast only when the displayed members belong to the native's birth moment.
            if let birth = hestia?.nativeEngraving(), let dna = birth.astroDNA, let sect = birth.sect,
               birth.tempus?.absoluteInstant.julianDay == frame.julianDay,
               let sun = linkedCoordinates.first(where: { $0.body == .sun }),
               let moon = linkedCoordinates.first(where: { $0.body == .moon }) {
                linkedFortune = try Hecate.castFortune(
                    ascendant: dna.longitude(of: .ascendant),
                    moon: CelestialLongitude(moon.directionalDegree.physicalDegrees)!,
                    sun: CelestialLongitude(sun.directionalDegree.physicalDegrees)!, sect: sect
                )
            }
        } catch { failure = String(describing: error) }
    }
}

private struct OrboRuntimeView: View {
    @ObservedObject var model: OrboApplicationModel
    @State private var name = "Ean Weslynn"
    @State private var date = "1985-04-10"
    @State private var time = "20:16"
    @State private var location = "Madison, WI"
    @State private var show3D = false
    @State private var cameraMode: IrisCameraMode = .topDown
    @State private var selectedBody: MundaneBody = .mercury
    @State private var selectedTab = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            if let failure = model.failure {
                Text(failure).foregroundStyle(.red).padding()
                    .accessibilityIdentifier("orbo.runtime.failure")
            }
            if let frame = model.frame {
                Group {
                    if selectedTab == 0 {
                    if let aegis = model.aegis {
                        ZStack {
                        IrisAstrolabeView(frame: IrisAstrolabeFrame(port: Apollo.signalForIris(aegis)),
                            pane: model.lunarPane, isLive: model.isLive, environment: model.environment,
                            select: { kind, gene in model.selectReading(kind, gene: gene) },
                            dismissPane: { model.lunarPane = nil }, goLive: model.goLive,
                            openHearth: { selectedTab = 1 }, openText: { selectedTab = 2 }, openInspect: { selectedTab = 3 },
                            controls: instrumentControls)
                        if model.tabulaVisible {
                            IrisTabulaView(selected: $model.tabulaSeat, returnToAegis: { model.tabulaVisible = false }) {
                                tabulaContent
                            }.padding(.top, 165).background(alignment: .bottom) {
                                Color(red: 0.04, green: 0.025, blue: 0.12).padding(.top, 160)
                            }
                        }
                        }
                    }
                    } else {
                        NavigationStack {
                            Group {
                                switch selectedTab {
                                case 1: birthForm
                                case 2: sky(frame)
                                default: diagnostics(frame)
                                }
                            }
                            .navigationTitle(selectedTab == 1 ? "Hearth" : selectedTab == 2 ? "Text" : "Inspect")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Astrolabe") { selectedTab = 0 }.accessibilityIdentifier("orbo.return")
                                }
                            }
                        }
                    }
                }
                .preferredColorScheme(selectedTab == 0 ? .dark : nil)
            } else if model.failure == nil {
                ProgressView("Opening Orbo…")
            }
        }
        .task(id: scenePhase == .active && selectedTab == 0) {
            guard scenePhase == .active && selectedTab == 0 else { return }
            var previous = ProcessInfo.processInfo.systemUptime
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(1.0 / 24)) }
                catch { return }
                let now = ProcessInfo.processInfo.systemUptime
                model.tick(seconds: now - previous)
                previous = now
            }
        }
    }

    private var instrumentControls: IrisAstrolabeControls {
        var controls = IrisAstrolabeControls()
        controls.playing = model.playing
        controls.horizonFrame = model.horizonFrame
        controls.aspects = model.aspects
        controls.heldBody = model.heldBody
        controls.courses = [.natal, .sky] + LunarCourse.allCases.filter { model.keptCourses.contains($0) && $0 != .natal && $0 != .sky }
        controls.selectAlmanacBody = { model.almanacBody = $0; model.selectCourse(.almanac) }
        if let aegis = model.aegis {
            controls.skyContacts = Apollo.contacts(in: aegis.sky, settings: model.aspects)
            controls.natalContacts = aegis.natal.map { Apollo.contacts(in: $0, settings: model.aspects) } ?? []
            controls.crossContacts = aegis.natal.map { Apollo.contacts(from: aegis.sky, to: $0, settings: model.aspects) } ?? []
        }
        controls.togglePlayback = model.togglePlayback
        controls.toggleFrame = { model.horizonFrame.toggle() }
        controls.openTabula = { model.tabulaVisible = true }
        controls.keepHearth = model.keepHearth
        controls.selectCourse = model.selectCourse
        controls.seek = model.jumpTo
        controls.beginScrub = { model.beginScrub($0, angle: $1, radius: $2) }
        controls.moveScrub = { model.moveScrub(angle: $0, radius: $1) }
        controls.endScrub = model.endScrub
        return controls
    }

    private func openCourse(_ course: LunarCourse) {
        model.selectCourse(course)
        model.tabulaVisible = false
    }

    @ViewBuilder private var tabulaContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch model.tabulaSeat {
            case .natal:
                Button(model.hestia?.hearthLit == true ? "Read my natal chart" : "Light my Hearth") {
                    if model.hestia?.hearthLit == true { openCourse(.natal) }
                    else { model.tabulaVisible = false; selectedTab = 1 }
                }
            case .hereNow:
                Text(model.aegis?.sky.place?.place.canonicalName ?? "Choose a birthplace at the Hearth")
                Button("Return to live sky") { model.goLive(); model.tabulaVisible = false }
                Button("Read the sky") { openCourse(.sky) }
            case .planets:
                ForEach(AstroDNAGene.canonicalOrder, id: \.self) { gene in
                    Button(gene.displayName) { model.selectReading(.sky, gene: gene); model.tabulaVisible = false }
                }
            case .moon:
                keepCourse(.moon)
                Button("Phase, illumination and mansion") { model.lunarEvents = false; openCourse(.moon) }
                Button("Ingress, prepared contacts and next eclipse") { model.lunarEvents = true; openCourse(.moon) }
            case .image:
                Toggle("Stars", isOn: $model.showStars)
            case .aspects:
                keepCourse(.relations)
                Toggle("Aspect web", isOn: $model.aspects.showWeb)
                ForEach(RingMark.allCases, id: \.self) { mark in
                    Toggle(String(describing: mark), isOn: Binding(get: { model.aspects.enabled.contains(mark) }, set: {
                        if $0 { model.aspects.enabled.insert(mark) } else { model.aspects.enabled.remove(mark) }
                    }))
                }
                Slider(value: $model.aspects.orb, in: 0...10, step: 0.5)
                Text("Orb · \(model.aspects.orb, specifier: "%.1f")°")
                Button("Read contacts") { openCourse(.relations) }
            case .ledger, .archive:
                Button("Keep my Hearth", action: model.keepHearth).disabled(model.hestia?.hearthLit != true)
                if !model.keeperMessage.isEmpty { Text(model.keeperMessage).font(.caption) }
                ForEach(model.keptHouses, id: \.nativeSubjectID) { house in
                    Button(house.nativeEngraving()?.name ?? "Kept chart") { model.restore(house) }
                }
                Button("Another birth chart") { model.tabulaVisible = false; selectedTab = 1 }
            case .timing:
                keepCourse(.timing)
                Picker("Return of", selection: $model.timingBody) {
                    ForEach(MundaneBody.canonicalOrder, id: \.self) { Text($0.displayName).tag($0) }
                }
                Text("Returns to the selected body's current degree and direction.").font(.caption)
                Button("Read returns") { openCourse(.timing) }
            case .almanac:
                keepCourse(.almanac)
                ForEach(ChronosAlmanacStream.allCases, id: \.self) { stream in
                    Toggle(stream.rawValue.capitalized, isOn: Binding(get: { model.almanacStreams.contains(stream) }, set: {
                        if $0 { model.almanacStreams.insert(stream) } else { model.almanacStreams.remove(stream) }
                    }))
                }
                Picker("Body", selection: $model.almanacBody) {
                    Text("ALL").tag(MundaneBody?.none)
                    ForEach(MundaneBody.canonicalOrder, id: \.self) { Text($0.displayName).tag(Optional($0)) }
                }
                Button("Read prepared stations") { openCourse(.almanac) }
            case .gears:
                Toggle("Horizon frame", isOn: $model.horizonFrame)
                Button(model.playing ? "Pause" : "Play", action: model.togglePlayback)
                Slider(value: $model.playSpeed, in: 1...24, step: 1)
                Text("\(Int(model.playSpeed)) \(model.horizonFrame ? "minutes" : "hours") per second")
                Slider(value: $model.aspects.magnetism, in: 0...1)
                Text("Magnetism · \(Int(model.aspects.magnetism * 100))%")
            case .composite:
                Text("Composite casting is not connected yet.").font(.caption)
                Button("Hecate's view of this sky", action: model.askHecate)
                ForEach(model.linkedCoordinates, id: \.body) { coordinate in
                    Text(IrisHoraeTextBodyRow(source: coordinate).displayText).font(.caption.monospaced())
                }
            }
        }.foregroundStyle(Color(red: 0.78, green: 0.75, blue: 0.88)).tint(.yellow)
    }

    private func keepCourse(_ course: LunarCourse) -> some View {
        Toggle("Keep on Lunar Pane", isOn: Binding(get: { model.keptCourses.contains(course) }, set: {
            if $0 { model.keptCourses.insert(course) } else { model.keptCourses.remove(course) }
        }))
    }

    private var birthForm: some View {
        Form {
            Section("Welcome, traveler") {
                TextField("Name", text: $name)
                TextField("Birth date · YYYY-MM-DD", text: $date).keyboardType(.numbersAndPunctuation)
                TextField("Local birth time · HH:MM", text: $time).keyboardType(.numbersAndPunctuation)
                TextField("Birth city and region", text: $location)
                Button("Begin") { Task { await model.submit(name: name, date: date, time: time, location: location) } }
                    .disabled(model.working)
                if model.working { ProgressView("Preparing your chart…") }
            }
            if let birth = model.hestia?.nativeEngraving(), let dna = birth.astroDNA {
                Section("\(birth.name) · Hearth lit") {
                    Button("See my natal chart") {
                        model.selectReading(.natal, gene: nil)
                        selectedTab = 0
                    }
                    Text(birth.topos?.place.canonicalName ?? birth.birthLocation)
                    Text("Sect: \(birth.sect?.rawValue ?? "")")
                    ForEach(AstroDNAGene.canonicalOrder, id: \.self) { gene in
                        let position = dna.longitude(of: gene)
                        LabeledContent(gene.displayName, value: String(format: "%.2f° %@%@",
                            position.degreeInSign.value, String(describing: position.sign).capitalized,
                            dna.motion(of: gene) == .retrograde ? " R" : ""))
                    }
                }.accessibilityIdentifier("orbo.hearth.lit")
                if let beat = model.orbo.bigThreeSession?.currentBeat {
                    Section {
                        ForEach(beat.orboLines, id: \.self) { Text($0) }
                        if beat.progress != .complete {
                            Button(beat.progress == .tourChoice ? "No thanks" : "Continue") { model.advanceIntroduction() }
                        }
                    }
                }
            }
        }.disabled(model.working)
    }

    private func sky(_ frame: IrisHoraeFrame) -> some View {
        VStack {
            HStack {
                Button("Previous day") { model.shift(days: -1) }
                Button("Next day") { model.shift(days: 1) }
                if #available(iOS 26.0, *) { Toggle("3D", isOn: $show3D) }
            }.padding()
            if #available(iOS 26.0, *), show3D {
                Picker("Perspective", selection: $cameraMode) {
                    Text("Top").tag(IrisCameraMode.topDown)
                    Text("Vertical").tag(IrisCameraMode.vertical)
                    Text("Horizontal").tag(IrisCameraMode.horizontal)
                }.pickerStyle(.segmented)
                IrisChart3DView(scene: frame.scene, presentation: IrisChart3DPresentation(
                    cameraProjection: .orthographic, cameraMode: cameraMode, orientationMode: .zodiacal
                ))
            } else { IrisHoraeTextView(frame: frame) }
        }
    }

    private func diagnostics(_ frame: IrisHoraeFrame) -> some View {
        Form {
            Section("Astrolabe sources") {
                Text("Natal: Hestia’s kept Tapestry · whole-sign houses · Rhea’s condition testimony")
                Text("Sky: OrboSpine through Horae · local ASC through Hecate · houses through Themis")
                ForEach(model.startupMeasurements, id: \.self) { Text($0) }
            }
            Section("Homer") {
                let state = model.orboPOV.pointOfView
                Text("Orbo: \(String(describing: state.backOfHouse))")
                let horaePOV = IrisHomerFrame(port: Homer.POV(Horae.signalForHomer(frame.output)))
                Text("Horae: JD \(horaePOV.pointOfView.julianDay.value)")
                if let journey = model.journeyPOV?.pointOfView {
                    Text("Hermes: \(String(describing: journey.currentState))")
                    ForEach(journey.events, id: \.sequence) { event in
                        Text("\(event.sequence). \(String(describing: event.kind)) · \(event.address?.rawValue ?? "")")
                    }
                }
                if let hecate = model.hecatePOV?.pointOfView {
                    Text("Hecate: \(hecate.kleis.id.rawValue)")
                }
            }
            Section("Chronos") {
                Picker("Body", selection: $selectedBody) {
                    ForEach(MundaneBody.canonicalOrder, id: \.self) { Text($0.displayName).tag($0) }
                }
                Button("Next occurrences of this position") { model.queryChronos(body: selectedBody, occurrences: true) }
                Button("Next stations") { model.queryChronos(body: selectedBody, occurrences: false) }
                if !model.chronology.isEmpty { Text(model.chronology).font(.caption.monospaced()).textSelection(.enabled) }
            }
            Section("Hecate · Door III") {
                Button("Read this frame’s Spine members") { model.askHecate() }
                ForEach(model.linkedCoordinates, id: \.body) { coordinate in
                    Text(IrisHoraeTextBodyRow(source: coordinate).displayText)
                }
                if let fortune = model.linkedFortune {
                    Text("Fortune: \(fortune.degrees, specifier: "%.4f")°")
                }
            }
        }
    }
}
