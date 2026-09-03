import SwiftUI
import OrboCore

/// The first native instrument surface. Commands leave through callbacks; all
/// displayed celestial values arrive in Apollo's existing standard Iris port.
public struct IrisAstrolabeView: View {
    public let frame: IrisAstrolabeFrame
    public let pane: IrisLunarPaneFrame?
    public let isLive: Bool
    public let environment: AetherEnvironment
    public let select: (AstrolabeChart.Kind, AstroDNAGene?) -> Void
    public let dismissPane: () -> Void
    public let goLive: () -> Void

    public init(frame: IrisAstrolabeFrame, pane: IrisLunarPaneFrame?, isLive: Bool, environment: AetherEnvironment,
                select: @escaping (AstrolabeChart.Kind, AstroDNAGene?) -> Void,
                dismissPane: @escaping () -> Void, goLive: @escaping () -> Void) {
        self.frame = frame; self.pane = pane; self.isLive = isLive
        self.environment = environment
        self.select = select; self.dismissPane = dismissPane; self.goLive = goLive
    }

    public var body: some View {
        if let aegis = frame.signal.aegis {
            GeometryReader { proxy in
                let width = min(proxy.size.width, 600)
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
                    VStack(spacing: 16) {
                        header(aegis).padding(.horizontal, 24).padding(.top, 14)
                        Spacer(minLength: 0)
                        wheel(aegis, diameter: min(width - 12, proxy.size.height * 0.64))
                        Spacer(minLength: 60)
                    }
                    .frame(width: width)
                    Image("orbo", bundle: .module).resizable().scaledToFit().frame(width: 40, height: 40)
                        .position(x: (proxy.size.width + width) / 2 - 35, y: 141)
                        .accessibilityHidden(true).allowsHitTesting(false)
                    VStack {
                        Spacer()
                        if let reading = pane?.signal.reading {
                            IrisLunarPaneView(reading: reading, hasNatal: aegis.natal != nil,
                                select: select, dismiss: dismissPane)
                                .frame(width: width, height: min(390, proxy.size.height * 0.54))
                        } else {
                            Button { select(aegis.natal == nil ? .sky : .natal, nil) } label: {
                                Text(aegis.natal == nil ? "THE SKY" : "MY NATAL CHART")
                                    .font(.system(size: 11, weight: .medium)).tracking(2)
                                    .foregroundStyle(IrisAstrolabeStyle.text)
                                    .frame(width: width, height: 70)
                                    .background(IrisAstrolabeStyle.ink.opacity(0.8), in: Ellipse())
                            }.accessibilityIdentifier("orbo.pane.open")
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
            .accessibilityIdentifier("orbo.astrolabe")
        }
    }

    private func header(_ aegis: ApolloAegis) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image("orbo-logo", bundle: .module).resizable().scaledToFit().frame(width: 76, height: 40)
                Spacer()
                Text("ASTROLABE").font(.system(size: 10)).tracking(2.5)
                    .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.45))
            }.padding(.bottom, 10)
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
            }
            .font(.system(size: 23, weight: .regular)).minimumScaleFactor(0.65).lineLimit(1)
            .accessibilityIdentifier("orbo.big-three")
            let date = Date(timeIntervalSince1970: (aegis.source.julianDay.value - 2440587.5) * 86400)
            Button(action: goLive) {
                Text(date.formatted(date: .abbreviated, time: .standard))
                    .font(.system(size: 12)).monospacedDigit().foregroundStyle(IrisAstrolabeStyle.text)
            }.accessibilityLabel("\(date.formatted()). Return to live sky")
            HStack {
                Spacer()
                Button(action: goLive) {
                    Text(isLive ? "• LIVE" : "RETURN TO LIVE").font(.system(size: 11)).tracking(2)
                        .foregroundStyle(IrisAstrolabeStyle.gold)
                }
                Spacer()
            }
            Text(aegis.sky.place?.place.canonicalName ?? "Set your birthplace at the Hearth for the local horizon")
                .font(.system(size: 9)).foregroundStyle(IrisAstrolabeStyle.text.opacity(0.6)).lineLimit(1)
        }
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
        let geometry = IrisAegisGeometry(diameter: diameter, horizon: aegis.sky.placement(.ascendant)?.longitude.degrees)
        let houseChart = aegis.natal ?? aegis.sky
        return ZStack {
            Circle().fill(RadialGradient(colors: [IrisAstrolabeStyle.ink, Color(red: 0.08, green: 0.045, blue: 0.22)], center: .center, startRadius: 0, endRadius: radius))
                .shadow(color: .black.opacity(0.6), radius: 9, y: 5)
            ForEach([0.99, 0.95, 0.83, 0.71, 0.64, 0.55], id: \.self) { ratio in
                Circle().stroke(IrisAstrolabeStyle.text.opacity(ratio > 0.9 ? 0.25 : 0.15), lineWidth: 0.8)
                    .frame(width: diameter * ratio, height: diameter * ratio)
            }
            Path { path in
                for degree in 0..<360 {
                    let a = geometry.point(longitude: Double(degree), radius: radius * 0.975)
                    let b = geometry.point(longitude: Double(degree), radius: radius * (degree % 10 == 0 ? 0.945 : 0.962))
                    path.move(to: a); path.addLine(to: b)
                }
                for sign in Sign.canonicalOrder {
                    path.move(to: geometry.point(longitude: Double(sign.rawValue * 30), radius: radius * 0.95))
                    path.addLine(to: geometry.point(longitude: Double(sign.rawValue * 30), radius: radius * 0.55))
                }
            }.stroke(IrisAstrolabeStyle.text.opacity(0.22), lineWidth: 0.65)
            ForEach(Sign.canonicalOrder, id: \.self) { sign in
                Text(IrisAstrolabeStyle.signs[sign.rawValue]).font(.system(size: 19))
                    .foregroundStyle(IrisAstrolabeStyle.color(sign))
                    .shadow(color: IrisAstrolabeStyle.color(sign).opacity(0.5), radius: 3)
                    .position(geometry.point(longitude: Double(sign.rawValue * 30 + 15), radius: radius * 0.88))
            }
            ForEach(houseChart.houses, id: \.house) { house in
                Text("\(house.house.rawValue)").font(.system(size: 9))
                    .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.45))
                    .position(geometry.point(longitude: Double(house.sign.rawValue * 30 + 15), radius: radius * 0.79))
            }
            if let natal = aegis.natal { occupants(natal, geometry: geometry, radius: radius * 0.60, lunar: nil) }
            occupants(aegis.sky, geometry: geometry, radius: radius * 0.75, lunar: aegis.lunarSeparation.degrees)
        }
        .frame(width: diameter, height: diameter)
    }

    private func occupants(_ chart: AstrolabeChart, geometry: IrisAegisGeometry, radius: Double, lunar: Double?) -> some View {
        ForEach(chart.placements, id: \.gene) { placement in
            let selected = pane?.signal.reading?.subject == chart.subject && pane?.signal.reading?.selectedGene == placement.gene
            Button { select(chart.kind, placement.gene) } label: {
                ZStack {
                    Circle().fill(IrisAstrolabeStyle.ink.opacity(0.6)).frame(width: 21, height: 21)
                    if placement.gene == .moon, let lunar {
                        IrisMoonFace(separation: lunar, color: IrisAstrolabeStyle.color(placement.longitude.sign)).frame(width: 18, height: 18)
                    } else {
                        Text(IrisAstrolabeStyle.glyph(placement.gene)).font(.system(size: chart.kind == .natal ? 15 : 21))
                            .foregroundStyle(chart.kind == .natal ? IrisAstrolabeStyle.text : IrisAstrolabeStyle.color(placement.longitude.sign))
                    }
                    if selected { Circle().stroke(IrisAstrolabeStyle.gold, lineWidth: 1).frame(width: 27, height: 27) }
                }.frame(width: 30, height: 30).contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(chart.kind == .natal ? chart.name : "Sky") \(placement.gene.displayName), \(IrisAstrolabeStyle.position(placement.longitude)) \(String(describing: placement.longitude.sign))")
            .accessibilityIdentifier("orbo.\(chart.kind.rawValue).\(placement.gene.rawValue)")
            .position(geometry.point(longitude: placement.longitude.degrees, radius: radius))
        }
    }
}
