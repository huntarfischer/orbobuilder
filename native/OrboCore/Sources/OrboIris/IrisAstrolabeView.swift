import SwiftUI
import OrboCore

/// Apollo supplies the two charts; Iris owns only their screen geometry and selection.
public struct IrisAstrolabeView: View {
    public let frame: IrisAstrolabeFrame
    public let pane: IrisLunarPaneFrame?
    public let isLive: Bool
    public let environment: AetherEnvironment
    public let select: (AstrolabeChart.Kind, AstroDNAGene?) -> Void
    public let dismissPane: () -> Void
    public let goLive: () -> Void
    public let openHearth: () -> Void
    public let openText: () -> Void
    public let openInspect: () -> Void
    public var controls = IrisAstrolabeControls()
    @State private var showSeats = false
    @State private var showCrowded = false
    @State private var crowded: [AstrolabePlacement] = []
    @State private var crowdedKind: AstrolabeChart.Kind = .natal
    @State private var activeScrub: AstroDNAGene?
    @Environment(\.scenePhase) private var scenePhase

    public init(frame: IrisAstrolabeFrame, pane: IrisLunarPaneFrame?, isLive: Bool, environment: AetherEnvironment,
                select: @escaping (AstrolabeChart.Kind, AstroDNAGene?) -> Void,
                dismissPane: @escaping () -> Void, goLive: @escaping () -> Void,
                openHearth: @escaping () -> Void, openText: @escaping () -> Void, openInspect: @escaping () -> Void,
                controls: IrisAstrolabeControls = IrisAstrolabeControls()) {
        self.frame = frame; self.pane = pane; self.isLive = isLive; self.environment = environment
        self.select = select; self.dismissPane = dismissPane; self.goLive = goLive
        self.openHearth = openHearth; self.openText = openText; self.openInspect = openInspect
        self.controls = controls
    }

    public var body: some View {
        if let aegis = frame.signal.aegis {
            GeometryReader { proxy in
                let width = min(proxy.size.width, 600)
                let diameter = min(width - 20, proxy.size.height * 0.62)
                ZStack(alignment: .top) {
                    LinearGradient(stops: (environment.celestialField.stops + environment.earthwardField.stops).map {
                        .init(color: Color(red: $0.color.red, green: $0.color.green, blue: $0.color.blue), location: $0.position)
                    }, startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                    ForEach(environment.starField.indices, id: \.self) { index in
                        let star = environment.starField[index]
                        Circle().fill(.white.opacity(star.intensity))
                            .frame(width: star.apparentRadius * 2, height: star.apparentRadius * 2)
                            .position(x: proxy.size.width * star.horizontalPosition, y: proxy.size.height * star.verticalPosition)
                    }.allowsHitTesting(false)
                    VStack(spacing: 0) {
                        header(aegis).padding(.horizontal, 22).padding(.top, 8)
                        ZStack(alignment: .top) {
                            if showSeats { seats(aegis).padding(.horizontal, 22).padding(.top, 8) }
                            wheel(aegis, diameter: diameter)
                                .padding(.top, showSeats ? 62 : max(28, proxy.size.height * 0.045))
                        }
                        Spacer(minLength: 0)
                    }.frame(width: width)
                    VStack {
                        Spacer(minLength: 0)
                        if let pane, pane.signal.course != nil {
                            IrisLunarSurface(signal: pane.signal, hasNatal: aegis.natal != nil, height: proxy.size.height,
                                select: select, course: controls.selectCourse, dismiss: dismissPane, goToMoment: controls.seek,
                                availableCourses: controls.courses, selectAlmanacBody: controls.selectAlmanacBody)
                                .frame(width: width)
                        } else {
                            Button { select(aegis.natal == nil ? .sky : .natal, nil) } label: {
                                Rectangle().fill(.clear).frame(width: width, height: 32)
                                    .background { IrisLunarPaneMaterial() }.contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open Lunar Pane")
                            .accessibilityIdentifier("orbo.pane.open")
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .confirmationDialog("Choose a placement", isPresented: $showCrowded, titleVisibility: .visible) {
                ForEach(crowded, id: \.gene) { placement in
                    Button("\(placement.gene.displayName) · \(IrisAstrolabeStyle.position(placement.longitude)) \(String(describing: placement.longitude.sign).capitalized)") {
                        select(crowdedKind, placement.gene)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .accessibilityElement(children: .contain)
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { activeScrub = nil; controls.endScrub() }
            }
        }
    }

    private func header(_ aegis: ApolloAegis) -> some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                if let logo = IrisAstrolabeArtwork.logo { logo.resizable().scaledToFit().frame(width: 55, height: 28) }
                Spacer()
                Text("ASTROLABE").font(.system(size: 10)).tracking(2.5)
                    .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.45))
            }.padding(.bottom, 18)
            HStack(spacing: 5) {
                headerPlacement(aegis.sky.placement(.ascendant), gene: .ascendant)
                Text("·").foregroundStyle(IrisAstrolabeStyle.text.opacity(0.45))
                if let moon = aegis.sky.placement(.moon) {
                    IrisMoonFace(separation: aegis.lunarSeparation.degrees, color: IrisAstrolabeStyle.color(moon.longitude.sign))
                        .frame(width: 15, height: 15)
                    headerPlacement(moon, gene: .moon)
                }
                Text("·").foregroundStyle(IrisAstrolabeStyle.text.opacity(0.45))
                headerPlacement(aegis.sky.placement(.sun), gene: .sun)
            }.font(.system(size: 23)).minimumScaleFactor(0.65).lineLimit(1)

            let date = Date(timeIntervalSince1970: ((aegis.source.julianDay.value - 2440587.5) * 86400).rounded())
            let civicLabel = date.formatted(date: .abbreviated, time: .standard) + " " + (TimeZone.current.abbreviation(for: date) ?? "")
            HStack(spacing: 7) {
                Button(action: goLive) {
                    Text(civicLabel)
                        .font(.system(size: 12)).monospacedDigit().lineLimit(1).minimumScaleFactor(0.8)
                }.accessibilityLabel("\(civicLabel). Return to live sky")
                    .accessibilityIdentifier("orbo.clock")
                Button { showSeats.toggle() } label: {
                    Text("⇅").font(.system(size: 12)).frame(width: 22, height: 22)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(IrisAstrolabeStyle.text.opacity(0.2)))
                }.accessibilityLabel("Show Plate and Rete").accessibilityIdentifier("orbo.seats")
            }.foregroundStyle(IrisAstrolabeStyle.text)
            Button(action: goLive) {
                Text(isLive ? "• LIVE" : "RETURN TO LIVE").font(.system(size: 11)).tracking(2)
                    .foregroundStyle(IrisAstrolabeStyle.gold).frame(minHeight: 20)
            }.accessibilityIdentifier("orbo.live")
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                // Temporary access to existing app surfaces, pending Hermes' Tabula.
                Menu {
                    Button("Tabula", action: controls.openTabula)
                    Button("Hearth", action: openHearth)
                    Button("Text", action: openText)
                    Button("Inspect", action: openInspect)
                } label: {
                    if let companion = IrisAstrolabeArtwork.companion {
                        companion.resizable().scaledToFit().frame(width: 40, height: 40)
                    } else { Image(systemName: "ellipsis.circle").frame(width: 40, height: 40) }
                }.accessibilityLabel("Orbo menu").accessibilityIdentifier("orbo.menu")
            }
            Text(aegis.sky.place?.place.canonicalName ?? "Set your birthplace at the Hearth for the local horizon")
                .font(.system(size: 9)).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.6)).lineLimit(1)
        }
    }

    private func seats(_ aegis: ApolloAegis) -> some View {
        HStack(spacing: 12) {
            seat("THE PLATE", name: aegis.natal?.name ?? "No natal chart",
                 subtitle: aegis.natal?.place?.place.canonicalName ?? "Light your Hearth") {
                if aegis.natal == nil { openHearth() } else { select(.natal, nil) }
            }
            seat("THE RETE", name: "The sky", subtitle: aegis.sky.place?.place.canonicalName ?? "No local horizon") { select(.sky, nil) }
        }.accessibilityElement(children: .contain)
    }

    private func seat(_ title: String, name: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 9)).tracking(1.5).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.5))
                Text(name).font(.system(size: 12))
                Text(subtitle).font(.system(size: 9)).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.65))
            }.lineLimit(1).frame(maxWidth: .infinity, alignment: .leading).padding(9)
                .background(.black.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(IrisAstrolabeStyle.text.opacity(0.25)))
        }.buttonStyle(.plain).foregroundStyle(IrisAstrolabeStyle.text)
    }

    private func headerPlacement(_ placement: AstrolabePlacement?, gene: AstroDNAGene) -> some View {
        Group {
            if let placement {
                Text("\(gene == .moon ? "" : IrisAstrolabeStyle.glyph(gene) + " ")\(IrisAstrolabeStyle.position(placement.longitude, precise: false))\(IrisAstrolabeStyle.signs[placement.longitude.sign.rawValue])")
                    .foregroundStyle(IrisAstrolabeStyle.color(placement.longitude.sign))
                    .accessibilityLabel("\(gene.displayName) \(IrisAstrolabeStyle.position(placement.longitude)) \(String(describing: placement.longitude.sign))")
            } else { Text("As —").foregroundStyle(IrisAstrolabeStyle.text.opacity(0.5)) }
        }
    }

    private func wheel(_ aegis: ApolloAegis, diameter: Double) -> some View {
        let radius = diameter / 2
        let horizon = controls.horizonFrame ? aegis.sky.placement(.ascendant)?.longitude.degrees : nil
        let geometry = IrisAegisGeometry(diameter: diameter, horizon: horizon)
        return ZStack {
            Circle().fill(RadialGradient(colors: [IrisAstrolabeStyle.ink, Color(red: 0.08, green: 0.045, blue: 0.22)], center: .center, startRadius: 0, endRadius: radius))
                .shadow(color: .black.opacity(0.6), radius: 7, y: 4)
            Circle().fill(.black.opacity(0.13)).frame(width: diameter * 0.68, height: diameter * 0.68)
            Circle().stroke(.clear, lineWidth: 24).contentShape(Circle().stroke(lineWidth: 24))
                .onTapGesture(count: 2, perform: controls.openTabula)
                .accessibilityLabel("Double tap rim for Tabula")
            ForEach([0.995, 0.98, 0.95, 0.83, 0.68, 0.55], id: \.self) { ratio in
                Circle().stroke(IrisAstrolabeStyle.text.opacity(ratio > 0.9 ? 0.25 : 0.15), lineWidth: 0.8)
                    .frame(width: diameter * ratio, height: diameter * ratio)
            }
            Path { path in
                for degree in 0..<360 {
                    let length: Double = degree % 30 == 0 ? 6 : degree % 10 == 0 ? 4.5 : degree % 5 == 0 ? 3.25 : 2
                    path.move(to: geometry.graduation(degree: Double(degree), radius: radius * 0.976))
                    path.addLine(to: geometry.graduation(degree: Double(degree), radius: radius * 0.976 - length))
                }
                for sign in Sign.canonicalOrder {
                    path.move(to: geometry.point(longitude: Double(sign.rawValue * 30), radius: radius * 0.95))
                    path.addLine(to: geometry.point(longitude: Double(sign.rawValue * 30), radius: radius * 0.55))
                }
            }.stroke(IrisAstrolabeStyle.text.opacity(0.24), lineWidth: 0.65).allowsHitTesting(false)
            ForEach(Sign.canonicalOrder, id: \.self) { sign in
                Text(IrisAstrolabeStyle.signs[sign.rawValue]).font(.system(size: 19))
                    .foregroundStyle(IrisAstrolabeStyle.color(sign))
                    .shadow(color: IrisAstrolabeStyle.color(sign).opacity(0.5), radius: 3)
                    .position(geometry.point(longitude: Double(sign.rawValue * 30 + 15), radius: radius * 0.88))
            }.allowsHitTesting(false)
            ForEach(aegis.sky.houses, id: \.house) { house in
                Text("\(house.house.rawValue)").font(.system(size: 9))
                    .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.45))
                    .position(geometry.point(longitude: Double(house.sign.rawValue * 30 + 15), radius: radius * 0.79))
            }.allowsHitTesting(false)
            if controls.aspects.showWeb {
                threads(aegis.sky, contacts: controls.skyContacts, geometry: geometry, radius: radius * 0.71, opacity: 0.45)
                if let natal = aegis.natal { threads(natal, contacts: controls.natalContacts, geometry: geometry, radius: radius * 0.60, opacity: 0.22) }
                if let natal = aegis.natal { crossThreads(aegis.sky, natal: natal, geometry: geometry, radius: radius) }
            }
            Button(action: controls.togglePlayback) {
                Image(systemName: controls.playing ? "pause.fill" : "play.fill")
                    .font(.system(size: 17)).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.4))
                    .frame(width: 60, height: 60).contentShape(Circle())
            }.buttonStyle(.plain).accessibilityLabel(controls.playing ? "Pause sky" : "Play sky")
                .accessibilityIdentifier("orbo.play")
                .highPriorityGesture(LongPressGesture(minimumDuration: 0.6).exclusively(before: TapGesture()).onEnded { action in
                    switch action {
                    case .first(true): controls.keepHearth()
                    case .second: controls.togglePlayback()
                    default: break
                    }
                })
                .accessibilityAction(named: Text("Keep my Hearth"), controls.keepHearth)
            if let natal = aegis.natal { occupants(natal, geometry: geometry, radius: radius, lunar: nil) }
            occupants(aegis.sky, geometry: geometry, radius: radius, lunar: aegis.lunarSeparation.degrees)
            if let ascendant = aegis.sky.placement(.ascendant) {
                let selected = pane?.signal.reading?.chart.kind == .sky && pane?.signal.reading?.selectedGene == .ascendant
                Path { path in
                    path.move(to: geometry.point(longitude: ascendant.longitude.degrees, radius: radius * 0.99))
                    path.addLine(to: geometry.point(longitude: ascendant.longitude.degrees + 180, radius: radius * 0.71))
                }.stroke(IrisAstrolabeStyle.color(ascendant.longitude.sign).opacity(0.35), lineWidth: 0.8).allowsHitTesting(false)
                Button { select(.sky, .ascendant) } label: {
                    Text("As").font(.system(size: 12, weight: .bold))
                        .foregroundStyle(IrisAstrolabeStyle.color(ascendant.longitude.sign))
                        .frame(width: 25, height: 25).background(IrisAstrolabeStyle.ink, in: Circle())
                        .overlay(Circle().stroke(selected ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.color(ascendant.longitude.sign), lineWidth: selected ? 2 : 1))
                        .frame(width: 44, height: 44).contentShape(Circle())
                }.buttonStyle(.plain)
                    .simultaneousGesture(scrubGesture(.ascendant, radius: radius))
                    .simultaneousGesture(TapGesture(count: 2).onEnded { controls.toggleFrame() })
                    .accessibilityLabel("Sky Ascendant, \(IrisAstrolabeStyle.position(ascendant.longitude))")
                    .accessibilityIdentifier("orbo.sky.Ascendant")
                    .accessibilityValue(selected ? "Selected" : "")
                    .position(geometry.point(longitude: ascendant.longitude.degrees, radius: radius * 0.99))
            }
        }.frame(width: diameter, height: diameter).coordinateSpace(name: "aegis")
            .accessibilityElement(children: .contain)
    }

    private func occupants(_ chart: AstrolabeChart, geometry: IrisAegisGeometry, radius: Double, lunar: Double?) -> some View {
        let placements = chart.placements.filter { chart.kind == .natal || $0.gene != .ascendant }
        let offsets = chart.kind == .sky ? IrisAegisGeometry.trackOffsets(placements) : [:]
        return ForEach(placements, id: \.gene) { placement in
            let natal = chart.kind == .natal
            let track = radius * (natal ? 0.60 : 0.75) - (offsets[placement.gene] ?? 0)
            let selected = pane?.signal.reading?.subject == chart.subject && pane?.signal.reading?.selectedGene == placement.gene
            Path { path in
                path.move(to: geometry.point(longitude: placement.longitude.degrees, radius: radius * (natal ? 0.63 : 0.71)))
                path.addLine(to: geometry.point(longitude: placement.longitude.degrees, radius: radius * 0.68))
            }.stroke(IrisAstrolabeStyle.text.opacity(0.4), lineWidth: 0.75).allowsHitTesting(false)
            Button {
                let point = geometry.point(longitude: placement.longitude.degrees, radius: track)
                let neighbors = placements.filter {
                    let other = geometry.point(longitude: $0.longitude.degrees,
                        radius: radius * (natal ? 0.60 : 0.75) - (offsets[$0.gene] ?? 0))
                    return hypot(point.x - other.x, point.y - other.y) < 22
                }
                if neighbors.count > 1 {
                    crowded = neighbors; crowdedKind = chart.kind; showCrowded = true
                } else { select(chart.kind, placement.gene) }
            } label: {
                ZStack {
                    Circle().fill(.black.opacity(natal ? 0.34 : 0.18))
                        .overlay(Circle().stroke(IrisAstrolabeStyle.text.opacity(natal ? 0.25 : 0.08), lineWidth: 0.65))
                        .frame(width: natal ? 15 : 21, height: natal ? 15 : 21)
                    if placement.gene == .moon, let lunar {
                        IrisMoonFace(separation: lunar, color: IrisAstrolabeStyle.color(placement.longitude.sign),
                            illuminationBearing: moonBearing(chart, geometry: geometry, radius: radius, offsets: offsets))
                            .frame(width: 18, height: 18)
                    } else {
                        Text(IrisAstrolabeStyle.glyph(placement.gene)).font(.system(size: natal ? 13 : 21))
                            .foregroundStyle(natal ? IrisAstrolabeStyle.text : IrisAstrolabeStyle.color(placement.longitude.sign))
                            .shadow(color: natal ? .black : IrisAstrolabeStyle.color(placement.longitude.sign).opacity(0.45), radius: natal ? 1 : 3, y: natal ? -1 : 0)
                    }
                    if selected { Circle().stroke(IrisAstrolabeStyle.gold, lineWidth: 1).frame(width: 25, height: 25) }
                }.frame(width: 30, height: 30).contentShape(Circle())
            }.buttonStyle(.plain)
                .simultaneousGesture(scrubGesture(placement.gene, radius: radius), including: natal ? .none : .all)
                .accessibilityLabel("\(chart.kind == .natal ? chart.name : "Sky") \(placement.gene.displayName), \(IrisAstrolabeStyle.position(placement.longitude))")
                .accessibilityIdentifier("orbo.\(chart.kind.rawValue).\(placement.gene.rawValue)")
                .position(geometry.point(longitude: placement.longitude.degrees, radius: track))
        }
    }

    private func threads(_ chart: AstrolabeChart, contacts: [ApolloContact], geometry: IrisAegisGeometry, radius: Double, opacity: Double) -> some View {
        ForEach(Array(contacts.enumerated()), id: \.offset) { _, contact in
            if let a = chart.placement(contact.left), let b = chart.placement(contact.right) {
                Path { path in
                    path.move(to: geometry.point(longitude: a.longitude.degrees, radius: radius))
                    path.addLine(to: geometry.point(longitude: b.longitude.degrees, radius: radius))
                }.stroke((contact.mark == .trine || contact.mark == .sextile ? Color.blue : Color.red).opacity(opacity), lineWidth: 1)
            }
        }.allowsHitTesting(false)
    }

    private func scrubGesture(_ gene: AstroDNAGene, radius: Double) -> some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .named("aegis"))
            .onChanged { value in
                func polar(_ point: CGPoint) -> (Double, Double) {
                    let x = point.x - radius, y = radius - point.y
                    return (atan2(y, x) * 180 / .pi, hypot(x, y))
                }
                if activeScrub == nil {
                    activeScrub = gene
                    let start = polar(value.startLocation)
                    controls.beginScrub(gene, start.0, start.1)
                }
                let current = polar(value.location)
                controls.moveScrub(current.0, current.1)
            }.onEnded { _ in activeScrub = nil; controls.endScrub() }
    }

    private func crossThreads(_ sky: AstrolabeChart, natal: AstrolabeChart, geometry: IrisAegisGeometry, radius: Double) -> some View {
        let offsets = IrisAegisGeometry.trackOffsets(sky.placements.filter { $0.gene != .ascendant })
        return ForEach(Array(controls.crossContacts.enumerated()), id: \.offset) { _, contact in
            if let a = sky.placement(contact.moving), let b = natal.placement(contact.natal) {
                let held = controls.heldBody == contact.moving
                Path { path in
                    path.move(to: geometry.point(longitude: a.longitude.degrees,
                        radius: a.gene == .ascendant ? radius * 0.99 : radius * 0.75 - (offsets[a.gene] ?? 0)))
                    path.addLine(to: geometry.point(longitude: b.longitude.degrees, radius: radius * 0.60))
                }.stroke((contact.mark == .trine || contact.mark == .sextile ? Color.blue : Color.red).opacity(held ? 0.8 : 0.12), lineWidth: held ? 1.8 : 0.6)
            }
        }.allowsHitTesting(false)
    }

    private func moonBearing(_ chart: AstrolabeChart, geometry: IrisAegisGeometry, radius: Double,
                             offsets: [AstroDNAGene: Double]) -> Double? {
        guard let sun = chart.placement(.sun), let moon = chart.placement(.moon) else { return nil }
        let a = geometry.point(longitude: sun.longitude.degrees, radius: radius * 0.75 - (offsets[.sun] ?? 0))
        let b = geometry.point(longitude: moon.longitude.degrees, radius: radius * 0.75 - (offsets[.moon] ?? 0))
        return atan2(Double(a.y - b.y), Double(a.x - b.x)) * 180 / .pi
    }
}
