import SwiftUI
import Foundation
import OrboCore

/// A thin monitor for Apollo's complete instrument signal. All device geometry,
/// material values, destination order, sky truth, and pose arrive from Apollo.
public struct IrisApolloAstrolabeView: View {
    public let frame: IrisPort<ApolloAstrolabeSignalFrame>

    public init(frame: IrisPort<ApolloAstrolabeSignalFrame>) {
        self.frame = frame
    }

    public var body: some View {
        GeometryReader { proxy in
            let instrument = frame.signal.instrument
            let diameter = min(proxy.size.width, proxy.size.height)
            let cosine = cos(instrument.rotationDegrees * .pi / 180)
            let faceWidth = max(0.001, abs(cosine))
            let edgeWidth = diameter * instrument.geometry.thicknessRatio

            ZStack {
                Ellipse()
                    .fill(.black.opacity(0.16))
                    .frame(width: diameter * (0.52 + 0.36 * faceWidth), height: diameter * 0.075)
                    .blur(radius: diameter * 0.025)
                    .offset(y: diameter * 0.54)

                Capsule()
                    .fill(edgeGradient(instrument.material))
                    .frame(width: max(edgeWidth, diameter * faceWidth), height: diameter * 0.985)
                    .overlay {
                        Capsule().stroke(color(instrument.material.engraving).opacity(0.35), lineWidth: 1)
                    }

                ZStack {
                    aegisFace(instrument)
                        .opacity(instrument.exposure.aegis > 0.001 ? 1 : 0)
                    tabulaFace(instrument)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .opacity(instrument.exposure.tabula > 0.001 ? 1 : 0)
                }
                .rotation3DEffect(
                    .degrees(instrument.rotationDegrees),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.42
                )
            }
            .frame(width: diameter, height: diameter)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Apollo Astrolabe, \(instrument.dominantFace.rawValue) face")
            .accessibilityValue("\(Int(instrument.rotationDegrees.rounded())) degrees")
            .accessibilityIdentifier("apollo.astrolabe.device")
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func aegisFace(_ instrument: ApolloAstrolabe) -> some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            let radius = diameter / 2
            let geometry = IrisAegisGeometry(diameter: diameter, horizon: nil)
            let material = instrument.material

            ZStack {
                stoneDisc(material)
                engravedRings(material, diameter: diameter)

                Path { path in
                    for degree in stride(from: 0, to: 360, by: 30) {
                        path.move(to: geometry.point(longitude: Double(degree), radius: radius * 0.97))
                        path.addLine(to: geometry.point(longitude: Double(degree), radius: radius * 0.80))
                    }
                }
                .stroke(color(material.engraving).opacity(0.28), lineWidth: 0.8)

                ForEach(Sign.canonicalOrder, id: \.self) { sign in
                    Text(IrisAstrolabeStyle.signs[sign.rawValue])
                        .font(.system(size: diameter * 0.043, weight: .light))
                        .foregroundStyle(IrisAstrolabeStyle.color(sign))
                        .position(geometry.point(
                            longitude: Double(sign.rawValue * 30 + 15),
                            radius: radius * 0.88
                        ))
                }

                ForEach(instrument.aegis.sky.placements, id: \.gene) { placement in
                    let track = radius * (0.63 - Double(placement.gene.ordinal % 3) * 0.055)
                    ZStack {
                        Circle()
                            .fill(color(material.edge).opacity(0.78))
                            .overlay(Circle().stroke(color(material.accent).opacity(0.52), lineWidth: 0.7))
                        Text(IrisAstrolabeStyle.glyph(placement.gene))
                            .font(.system(size: diameter * 0.044, weight: .medium))
                            .foregroundStyle(IrisAstrolabeStyle.color(placement.longitude.sign))
                    }
                    .frame(width: diameter * 0.075, height: diameter * 0.075)
                    .position(geometry.point(longitude: placement.longitude.degrees, radius: track))
                }

                VStack(spacing: diameter * 0.014) {
                    Text("AEGIS")
                        .font(.system(size: diameter * 0.046, weight: .light, design: .serif))
                        .tracking(diameter * 0.012)
                    Text("APOLLO")
                        .font(.system(size: diameter * 0.021, weight: .medium))
                        .tracking(diameter * 0.012)
                        .foregroundStyle(color(material.accent))
                    Text("HORAe · \(String(format: "%.5f", instrument.aegis.source.julianDay.value))")
                        .font(.system(size: diameter * 0.013, weight: .regular, design: .monospaced))
                        .foregroundStyle(color(material.engraving).opacity(0.52))
                }
                .foregroundStyle(color(material.engraving))
            }
            .frame(width: diameter, height: diameter)
        }
    }

    private func tabulaFace(_ instrument: ApolloAstrolabe) -> some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            let radius = diameter / 2
            let geometry = IrisAegisGeometry(diameter: diameter, horizon: nil)
            let material = instrument.material

            ZStack {
                stoneDisc(material)
                engravedRings(material, diameter: diameter)

                Path { path in
                    for degree in stride(from: 0, to: 360, by: 30) {
                        path.move(to: geometry.point(longitude: Double(degree), radius: radius * 0.97))
                        path.addLine(to: geometry.point(longitude: Double(degree), radius: radius * 0.53))
                    }
                }
                .stroke(color(material.engraving).opacity(0.32), lineWidth: 0.8)

                ForEach(ApolloTabulaDestination.allCases, id: \.self) { destination in
                    let longitude = Double(destination.rawValue * 30 + 15)
                    VStack(spacing: diameter * 0.007) {
                        Text(destination.glyph)
                            .font(.system(size: diameter * 0.043, weight: .light))
                        Text(destination.title.uppercased())
                            .font(.system(size: diameter * 0.012, weight: .medium, design: .serif))
                            .tracking(diameter * 0.0015)
                    }
                    .foregroundStyle(destination == .natal ? color(material.accent) : color(material.engraving).opacity(0.72))
                    .position(geometry.point(longitude: longitude, radius: radius * 0.76))
                }

                VStack(spacing: diameter * 0.018) {
                    Text("TABULA")
                        .font(.system(size: diameter * 0.047, weight: .light, design: .serif))
                        .tracking(diameter * 0.014)
                    Text("APOLLO")
                        .font(.system(size: diameter * 0.021, weight: .medium))
                        .tracking(diameter * 0.012)
                        .foregroundStyle(color(material.accent))
                    Capsule()
                        .stroke(color(material.engraving).opacity(0.48), lineWidth: 0.8)
                        .frame(width: diameter * 0.19, height: diameter * 0.07)
                        .overlay {
                            Text("AEGIS")
                                .font(.system(size: diameter * 0.017, weight: .medium))
                                .tracking(diameter * 0.008)
                        }
                }
                .foregroundStyle(color(material.engraving))
            }
            .frame(width: diameter, height: diameter)
        }
    }

    private func stoneDisc(_ material: ApolloAstrolabeMaterial) -> some View {
        Circle()
            .fill(RadialGradient(
                colors: [color(material.faceHighlight), color(material.face), color(material.edge)],
                center: .init(x: 0.38, y: 0.30),
                startRadius: 2,
                endRadius: 320
            ))
            .overlay {
                Canvas { context, size in
                    for index in 0..<150 {
                        let x = pseudo(index * 47) * size.width
                        let y = pseudo(index * 89 + 17) * size.height
                        let opacity = 0.018 + pseudo(index * 13) * 0.035
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: 1.2, height: 1.2)),
                            with: .color(.white.opacity(opacity))
                        )
                    }
                }
                .clipShape(Circle())
                .allowsHitTesting(false)
            }
            .overlay(Circle().stroke(color(material.engraving).opacity(0.42), lineWidth: 1))
            .overlay(Circle().inset(by: 4).stroke(color(material.edge).opacity(0.9), lineWidth: 2))
    }

    private func engravedRings(_ material: ApolloAstrolabeMaterial, diameter: Double) -> some View {
        ZStack {
            ForEach([0.97, 0.94, 0.80, 0.69, 0.54], id: \.self) { ratio in
                Circle()
                    .stroke(color(material.engraving).opacity(ratio > 0.9 ? 0.34 : 0.23), lineWidth: 0.8)
                    .frame(width: diameter * ratio, height: diameter * ratio)
            }
        }
    }

    private func edgeGradient(_ material: ApolloAstrolabeMaterial) -> LinearGradient {
        LinearGradient(
            colors: [color(material.edge), color(material.faceHighlight), color(material.edge)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func color(_ value: ApolloAstrolabeColor) -> Color {
        Color(red: value.red, green: value.green, blue: value.blue, opacity: value.alpha)
    }

    private func pseudo(_ seed: Int) -> Double {
        Double((seed * 1_103_515_245 &+ 12_345) & 0x7fffffff) / Double(0x7fffffff)
    }
}
