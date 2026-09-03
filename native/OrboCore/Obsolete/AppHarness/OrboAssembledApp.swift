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
    private(set) var horae: Horae?
    private var started = false

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
            let mounted = try await Task.detached(priority: .userInitiated) {
                try OrboSpineRuntime.load(from: root)
            }.value
            let horae = Horae(locate: mounted.locate)
            self.runtime = mounted
            self.horae = horae
            self.session = try IrisHoraeControlSession(horae: horae, initialJulianDay: horae.live().julianDay)
            if CommandLine.arguments.contains("--orbo-birth-proof") {
                await submit(name: "Ean Weslynn", date: "1985-04-10", time: "20:16", location: "Madison, WI")
            }
            FileHandle.standardOutput.write(Data("ORBO_READY: real Spine mounted\n".utf8))
        } catch { failure = String(describing: error) }
    }

    func shift(days: Double) {
        guard let horae, var session else { return }
        do {
            try session.shift(by: HoraeUTOffset(days: days)!, through: horae)
            self.session = session
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
        orbo = result.0
        hermes = result.1
        hestia = result.2
        noticeTicket = result.3
        failure = result.4
        if let birth = hestia?.nativeEngraving(), let tempus = birth.tempus, let dna = birth.astroDNA {
            do {
                session = try IrisHoraeControlSession(horae: horae, initialJulianDay: tempus.absoluteInstant.julianDay)
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

    var body: some View {
        VStack {
            if let failure = model.failure {
                Text(failure).foregroundStyle(.red).padding()
                    .accessibilityIdentifier("orbo.runtime.failure")
            }
            if let frame = model.frame {
                TabView {
                    birthForm.tabItem { Label("Birth", systemImage: "person") }
                    sky(frame).tabItem { Label("Sky", systemImage: "sparkles") }
                    diagnostics(frame).tabItem { Label("Inspect", systemImage: "list.bullet.rectangle") }
                }
            } else if model.failure == nil {
                ProgressView("Opening Orbo…")
            }
        }
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
