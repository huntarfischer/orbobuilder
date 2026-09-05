import SwiftUI
import Foundation
import OrboCore

/// Iris displays Apollo's immutable instrument signal and returns only
/// Apollo-authored mechanical commands. Geometry, meaning, state, and sky
/// truth remain on the far side of the port with Apollo.
public struct IrisApolloAstrolabeView: View {
    public let frame: IrisPort<ApolloAstrolabeSignalFrame>
    public let onCommand: (ApolloAstrolabeCommand) -> Void
    @State private var dragOrigin: Double?

    public init(
        frame: IrisPort<ApolloAstrolabeSignalFrame>,
        onCommand: @escaping (ApolloAstrolabeCommand) -> Void = { _ in }
    ) {
        self.frame = frame
        self.onCommand = onCommand
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
                    .fill(.black.opacity(0.18))
                    .frame(width: diameter * (0.52 + 0.36 * faceWidth), height: diameter * 0.075)
                    .blur(radius: diameter * 0.025)
                    .offset(y: diameter * 0.54)

                Capsule()
                    .fill(edgeGradient(instrument.material))
                    .frame(width: max(edgeWidth, diameter * faceWidth), height: diameter * 0.985)
                    .overlay {
                        Capsule().stroke(color(instrument.material.engraving).opacity(0.28), lineWidth: 1)
                    }

                ZStack {
                    aegisFace(instrument)
                        .opacity(instrument.exposure.aegis > 0.001 ? 1 : 0)
                        .allowsHitTesting(instrument.exposure.aegis > 0.001)
                    tabulaFace(instrument)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .opacity(instrument.exposure.tabula > 0.001 ? 1 : 0)
                        .allowsHitTesting(instrument.exposure.tabula > 0.001)
                }
                .rotation3DEffect(
                    .degrees(instrument.rotationDegrees),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.42
                )
            }
            .frame(width: diameter, height: diameter)
            .contentShape(Rectangle())
            .simultaneousGesture(turnGesture(instrument))
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Apollo Astrolabe, \(instrument.dominantFace.rawValue) face")
            .accessibilityValue("\(Int(instrument.rotationDegrees.rounded())) degrees")
            .accessibilityIdentifier("apollo.astrolabe.device")
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func turnGesture(_ instrument: ApolloAstrolabe) -> some Gesture {
        DragGesture(minimumDistance: 7)
            .onChanged { value in
                if dragOrigin == nil { dragOrigin = instrument.rotationDegrees }
                onCommand(.turn((dragOrigin ?? instrument.rotationDegrees) + Double(value.translation.width) * 0.72))
            }
            .onEnded { _ in
                dragOrigin = nil
                onCommand(.settle)
            }
    }

    private func aegisFace(_ instrument: ApolloAstrolabe) -> some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            let radius = diameter / 2
            let geometry = IrisAegisGeometry(diameter: diameter, horizon: nil)
            let material = instrument.material

            ZStack {
                stoneDisc(material)

                ForEach([0.986, 0.970, 0.950, 0.830, 0.680, 0.550], id: \.self) { ratio in
                    Circle()
                        .stroke(color(material.engraving).opacity(ratio > 0.9 ? 0.25 : 0.15), lineWidth: 0.75)
                        .frame(width: diameter * ratio, height: diameter * ratio)
                }

                Canvas { context, _ in
                    var graduations = Path()
                    for degree in 0..<360 {
                        let length: Double = degree % 30 == 0 ? 6 : degree % 10 == 0 ? 4.5 : degree % 5 == 0 ? 3.25 : 2
                        graduations.move(to: geometry.graduation(degree: Double(degree), radius: radius * 0.976))
                        graduations.addLine(to: geometry.graduation(degree: Double(degree), radius: radius * 0.976 - length))
                    }
                    for sign in Sign.canonicalOrder {
                        graduations.move(to: geometry.point(longitude: Double(sign.rawValue * 30), radius: radius * 0.95))
                        graduations.addLine(to: geometry.point(longitude: Double(sign.rawValue * 30), radius: radius * 0.55))
                    }
                    context.stroke(graduations, with: .color(color(material.engraving).opacity(0.22)), lineWidth: 0.65)

                    for contact in instrument.skyContacts {
                        guard let left = instrument.aegis.sky.placement(contact.left),
                              let right = instrument.aegis.sky.placement(contact.right) else { continue }
                        var thread = Path()
                        thread.move(to: geometry.point(longitude: left.longitude.degrees, radius: radius * 0.71))
                        thread.addLine(to: geometry.point(longitude: right.longitude.degrees, radius: radius * 0.71))
                        let harmonious = contact.mark == .trine || contact.mark == .sextile
                        context.stroke(thread, with: .color((harmonious ? Color.blue : Color.red).opacity(0.48)), lineWidth: 0.8)
                    }
                }
                .allowsHitTesting(false)

                ForEach(Sign.canonicalOrder, id: \.self) { sign in
                    Text(IrisAstrolabeStyle.signs[sign.rawValue])
                        .font(.system(size: diameter * 0.043, weight: .light))
                        .foregroundStyle(IrisAstrolabeStyle.color(sign))
                        .shadow(color: IrisAstrolabeStyle.color(sign).opacity(0.35), radius: 2)
                        .position(geometry.point(
                            longitude: Double(sign.rawValue * 30 + 15),
                            radius: radius * 0.88
                        ))
                }

                ForEach(instrument.aegis.sky.placements, id: \.gene) { placement in
                    let track = radius * (0.70 - Double(placement.gene.ordinal % 3) * 0.048)
                    ZStack {
                        Circle()
                            .fill(color(material.edge).opacity(0.82))
                            .overlay(Circle().stroke(color(material.accent).opacity(0.40), lineWidth: 0.7))
                        Text(IrisAstrolabeStyle.glyph(placement.gene))
                            .font(.system(size: diameter * 0.043, weight: .medium))
                            .foregroundStyle(IrisAstrolabeStyle.color(placement.longitude.sign))
                    }
                    .frame(width: diameter * 0.070, height: diameter * 0.070)
                    .position(geometry.point(longitude: placement.longitude.degrees, radius: track))
                }

                Image(systemName: "play.fill")
                    .font(.system(size: diameter * 0.055))
                    .foregroundStyle(color(material.engraving).opacity(0.40))

                rimFlipControl(diameter: diameter)
            }
            .frame(width: diameter, height: diameter)
        }
    }

    private func tabulaFace(_ instrument: ApolloAstrolabe) -> some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            let material = instrument.material
            let tabula = instrument.tabula

            ZStack {
                stoneDisc(material)
                tabulaEngraving(instrument, diameter: diameter)
                destinationLabels(instrument, diameter: diameter)
                destinationControls(instrument)

                if let destination = tabula.destination {
                    socketRing(instrument, diameter: diameter)
                    socketControls(instrument)
                    tabulaField(destination, instrument: instrument, diameter: diameter)
                } else {
                    VStack(spacing: diameter * 0.006) {
                        Text("THE TABULA")
                        Text("APOLLO")
                        Text(String(format: "%.5f", instrument.aegis.source.julianDay.value))
                    }
                    .font(.system(size: diameter * 0.022, weight: .semibold, design: .serif))
                    .tracking(diameter * 0.0048)
                    .foregroundStyle(color(material.accent))
                    .multilineTextAlignment(.center)
                }

                rimFlipControl(diameter: diameter)
            }
            .frame(width: diameter, height: diameter)
        }
    }

    private func tabulaEngraving(_ instrument: ApolloAstrolabe, diameter: Double) -> some View {
        let geometry = instrument.geometry
        let material = instrument.material
        let selected = instrument.tabula.destination
        return Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let line = color(material.engraving)

            for radius in [geometry.rimRadius, 0.38, geometry.inscriptionInnerRadius] {
                let shadow = circlePath(in: rect, radius: radius, yOffset: diameter * 0.003)
                context.stroke(shadow, with: .color(.black.opacity(0.48)), lineWidth: radius == geometry.rimRadius ? 1.25 : 0.9)
                context.stroke(circlePath(in: rect, radius: radius), with: .color(line.opacity(radius == geometry.rimRadius ? 0.28 : 0.18)), lineWidth: radius == geometry.rimRadius ? 1.05 : 0.75)
            }

            for destination in ApolloTabulaDestination.allCases {
                let start = 180 + Double(destination.rawValue * 30)
                let sector = AnnularSector(startDegrees: start, endDegrees: start + 30,
                    innerRadius: geometry.destinationInnerRadius, outerRadius: 0.49).path(in: rect)
                if selected == destination {
                    context.fill(sector, with: .color(color(material.accent).opacity(0.14)))
                } else if selected != nil {
                    context.fill(sector, with: .color(.black.opacity(0.22)))
                } else {
                    context.fill(sector, with: .color(.white.opacity(0.025)))
                }
                context.stroke(sector, with: .color(line.opacity(0.15)), lineWidth: 0.75)
            }
        }
        .allowsHitTesting(false)
    }

    private func destinationLabels(_ instrument: ApolloAstrolabe, diameter: Double) -> some View {
        let selected = instrument.tabula.destination
        let material = instrument.material
        return ZStack {
            ForEach(ApolloTabulaDestination.allCases, id: \.self) { destination in
                let angle = 180 + Double(destination.rawValue * 30 + 15)
                let active = selected == destination
                let dimmed = selected != nil && !active
                Text(destination.glyph)
                    .font(.system(size: diameter * 0.044, weight: .light))
                    .foregroundStyle(active ? color(material.accent) : color(material.engraving).opacity(dimmed ? 0.25 : 0.64))
                    .position(instrumentPoint(angle: angle, radius: instrument.geometry.zodiacGlyphRadius * diameter, diameter: diameter))

                ArcLabel(
                    text: destination.title.uppercased(),
                    centerAngle: angle,
                    radiusRatio: sin(angle * .pi / 180) > 0 ? 0.344 : 0.366,
                    fontRatio: 0.021,
                    color: active ? color(material.accent) : color(material.engraving).opacity(dimmed ? 0.24 : 0.62)
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func destinationControls(_ instrument: ApolloAstrolabe) -> some View {
        ZStack {
            ForEach(ApolloTabulaDestination.allCases, id: \.self) { destination in
                let start = 180 + Double(destination.rawValue * 30)
                Button {
                    onCommand(.selectDestination(instrument.tabula.destination == destination ? nil : destination))
                } label: {
                    AnnularSector(startDegrees: start, endDegrees: start + 30,
                        innerRadius: instrument.geometry.destinationInnerRadius, outerRadius: 0.49)
                        .fill(.white.opacity(0.001))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(destination.title) Tabula")
                .accessibilityValue(instrument.tabula.destination == destination ? "Selected" : "")
                .accessibilityIdentifier("apollo.tabula.\(destination.rawValue)")
            }
        }
    }

    private func socketRing(_ instrument: ApolloAstrolabe, diameter: Double) -> some View {
        let material = instrument.material
        let modes = instrument.tabula.destination == .planets ? ApolloTabulaBodyMode.allCases : []
        return ZStack {
            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                for j in -5...6 {
                    let center = 90 - Double(j * 30)
                    let sector = AnnularSector(startDegrees: center - 15, endDegrees: center + 15,
                        innerRadius: instrument.geometry.socketInnerRadius,
                        outerRadius: instrument.geometry.socketOuterRadius).path(in: rect)
                    let modeIndex = j + 1
                    let mode = modes.indices.contains(modeIndex) ? modes[modeIndex] : nil
                    let active = mode == instrument.tabula.bodyMode
                    let isAegis = j == 6
                    let fill: Color = active ? color(material.accent).opacity(0.15)
                        : isAegis ? color(material.accent).opacity(0.055)
                        : mode != nil ? .white.opacity(0.022) : .black.opacity(0.16)
                    let stroke: Color = active ? color(material.accent).opacity(0.55)
                        : isAegis ? color(material.accent).opacity(0.20)
                        : color(material.engraving).opacity(0.10)
                    context.fill(sector, with: .color(fill))
                    context.stroke(sector, with: .color(stroke), lineWidth: 0.72)
                }
            }
            .allowsHitTesting(false)

            ForEach(Array(modes.enumerated()), id: \.element) { index, mode in
                let j = index - 1
                let angle = 90 - Double(j * 30)
                ArcLabel(
                    text: mode.socketTitle.uppercased(),
                    centerAngle: angle,
                    radiusRatio: sin(angle * .pi / 180) > 0 ? 0.279 : 0.312,
                    fontRatio: 0.0185,
                    color: mode == instrument.tabula.bodyMode
                        ? color(material.accent)
                        : color(material.engraving).opacity(0.60)
                )
            }

            ArcLabel(text: "AEGIS", centerAngle: -90, radiusRatio: 0.312,
                fontRatio: 0.0185, color: color(material.accent).opacity(0.80))
        }
    }

    private func socketControls(_ instrument: ApolloAstrolabe) -> some View {
        ZStack {
            if instrument.tabula.destination == .planets {
                ForEach(Array(ApolloTabulaBodyMode.allCases.enumerated()), id: \.element) { index, mode in
                    let j = index - 1
                    let angle = 90 - Double(j * 30)
                    Button { onCommand(.selectBodyMode(mode)) } label: {
                        AnnularSector(startDegrees: angle - 15, endDegrees: angle + 15,
                            innerRadius: instrument.geometry.socketInnerRadius,
                            outerRadius: instrument.geometry.socketOuterRadius)
                            .fill(.white.opacity(0.001))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(mode.socketTitle)
                    .accessibilityValue(instrument.tabula.bodyMode == mode ? "Selected" : "")
                    .accessibilityIdentifier("apollo.tabula.body.\(mode.rawValue)")
                }
            }

            Button { onCommand(.flip) } label: {
                AnnularSector(startDegrees: -105, endDegrees: -75,
                    innerRadius: instrument.geometry.socketInnerRadius,
                    outerRadius: instrument.geometry.socketOuterRadius)
                    .fill(.white.opacity(0.001))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Return to Aegis")
            .accessibilityIdentifier("apollo.tabula.aegis")
        }
    }

    @ViewBuilder
    private func tabulaField(
        _ destination: ApolloTabulaDestination,
        instrument: ApolloAstrolabe,
        diameter: Double
    ) -> some View {
        if destination == .planets {
            ZStack {
                ForEach(Array(instrument.tabula.bodyChips.enumerated()), id: \.offset) { _, chip in
                    tabulaChip(chip, material: instrument.material, diameter: diameter)
                }
                Text(instrument.tabula.bodyMode.fieldTitle)
                    .font(.system(size: diameter * 0.021, weight: .semibold, design: .serif))
                    .tracking(diameter * 0.003)
                    .foregroundStyle(color(instrument.material.accent))
            }
        } else {
            Text("THE \(destination.title.uppercased())")
                .font(.system(size: diameter * 0.021, weight: .semibold, design: .serif))
                .tracking(diameter * 0.003)
                .foregroundStyle(color(instrument.material.accent))
        }
    }

    private func tabulaChip(
        _ chip: ApolloTabulaChip,
        material: ApolloAstrolabeMaterial,
        diameter: Double
    ) -> some View {
        let disc = min(26, diameter * 0.071)
        let radius = diameter * 0.264 - (disc / 2 + 13)
        let point = instrumentPoint(angle: chip.angleDegrees, radius: radius, diameter: diameter)
        let top = sin(chip.angleDegrees * .pi / 180) > 0.001
        let foreground = chip.enabled ? color(material.engraving) : color(material.engraving).opacity(0.25)
        let border = chip.enabled ? color(material.accent).opacity(0.42) : color(material.engraving).opacity(0.12)
        return ZStack {
            Circle()
                .fill(color(material.edge).opacity(0.86))
                .overlay(Circle().stroke(border, lineWidth: 0.75))
            Text(chip.glyph)
                .font(.system(size: disc * (chip.glyph.count > 1 ? 0.43 : 0.62), weight: .regular))
                .foregroundStyle(foreground)
            Text(chip.name)
                .font(.system(size: min(7.5, diameter * 0.019), weight: .regular))
                .foregroundStyle(chip.enabled ? color(material.engraving).opacity(0.68) : color(material.engraving).opacity(0.25))
                .fixedSize()
                .offset(y: top ? disc * 0.82 : -disc * 0.82)
        }
        .frame(width: disc, height: disc)
        .position(point)
        .allowsHitTesting(false)
    }

    private func rimFlipControl(diameter: Double) -> some View {
        Circle()
            .stroke(.clear, lineWidth: diameter * 0.095)
            .contentShape(Circle().stroke(lineWidth: diameter * 0.12))
            .padding(diameter * 0.015)
            .onTapGesture(count: 2) { onCommand(.flip) }
            .accessibilityLabel("Flip Apollo Astrolabe")
            .accessibilityHint("Double tap the rim")
    }

    private func stoneDisc(_ material: ApolloAstrolabeMaterial) -> some View {
        Circle()
            .fill(RadialGradient(
                colors: [color(material.faceHighlight), color(material.face), color(material.edge)],
                center: .init(x: 0.44, y: 0.38),
                startRadius: 2,
                endRadius: 330
            ))
            .overlay {
                Canvas { context, size in
                    for index in 0..<220 {
                        let x = pseudo(index * 47) * size.width
                        let y = pseudo(index * 89 + 17) * size.height
                        let scale = 0.8 + pseudo(index * 29) * 3.8
                        let opacity = 0.012 + pseudo(index * 13) * 0.030
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: scale, height: scale * 0.72)),
                            with: .color(.white.opacity(opacity))
                        )
                    }
                    for index in 0..<34 {
                        let x = pseudo(index * 61 + 7) * size.width
                        let y = pseudo(index * 31 + 41) * size.height
                        let scale = size.width * (0.025 + pseudo(index * 19) * 0.07)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: scale, height: scale)),
                            with: .radialGradient(
                                Gradient(colors: [.white.opacity(0.018), .clear]),
                                center: CGPoint(x: x + scale / 2, y: y + scale / 2),
                                startRadius: 0,
                                endRadius: scale / 2
                            )
                        )
                    }
                }
                .clipShape(Circle())
                .allowsHitTesting(false)
            }
            .overlay(Circle().stroke(color(material.engraving).opacity(0.30), lineWidth: 1))
            .overlay(Circle().inset(by: 4).stroke(color(material.edge).opacity(0.94), lineWidth: 2))
            .shadow(color: .black.opacity(0.48), radius: 5, y: 3)
    }

    private func circlePath(in rect: CGRect, radius: Double, yOffset: Double = 0) -> Path {
        let d = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY + yOffset)
        return Path(ellipseIn: CGRect(
            x: center.x - d * radius,
            y: center.y - d * radius,
            width: d * radius * 2,
            height: d * radius * 2
        ))
    }

    private func instrumentPoint(angle: Double, radius: Double, diameter: Double) -> CGPoint {
        let radians = angle * .pi / 180
        return CGPoint(
            x: diameter / 2 + radius * cos(radians),
            y: diameter / 2 - radius * sin(radians)
        )
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
        Double((seed &* 1_103_515_245 &+ 12_345) & 0x7fffffff) / Double(0x7fffffff)
    }
}

private struct AnnularSector: Shape {
    let startDegrees: Double
    let endDegrees: Double
    let innerRadius: Double
    let outerRadius: Double

    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        func point(_ angle: Double, _ radius: Double) -> CGPoint {
            let radians = angle * .pi / 180
            return CGPoint(
                x: center.x + diameter * radius * cos(radians),
                y: center.y - diameter * radius * sin(radians)
            )
        }
        let steps = max(3, Int(abs(endDegrees - startDegrees) / 2))
        var path = Path()
        path.move(to: point(startDegrees, outerRadius))
        for index in 1...steps {
            let angle = startDegrees + (endDegrees - startDegrees) * Double(index) / Double(steps)
            path.addLine(to: point(angle, outerRadius))
        }
        for index in stride(from: steps, through: 0, by: -1) {
            let angle = startDegrees + (endDegrees - startDegrees) * Double(index) / Double(steps)
            path.addLine(to: point(angle, innerRadius))
        }
        path.closeSubpath()
        return path
    }
}

/// SwiftUI has no native text-on-path primitive. This transcribes the
/// prototype's SVG textPath law by placing each character on the same arc and
/// reversing the lower-half baseline so every inscription remains upright.
private struct ArcLabel: View {
    let text: String
    let centerAngle: Double
    let radiusRatio: Double
    let fontRatio: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            let characters = Array(text)
            let top = sin(centerAngle * .pi / 180) > 0
            let span = min(25.0, max(5.0, Double(max(1, characters.count - 1)) * 2.65))
            ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                let progress = characters.count == 1 ? 0.5 : Double(index) / Double(characters.count - 1)
                let angle = centerAngle + (top ? 1 : -1) * (span / 2 - span * progress)
                let radians = angle * .pi / 180
                let rotation = top ? 90 - angle : 270 - angle
                Text(String(character))
                    .font(.system(size: diameter * fontRatio, weight: .regular, design: .serif))
                    .foregroundStyle(color)
                    .rotationEffect(.degrees(rotation))
                    .position(
                        x: diameter / 2 + diameter * radiusRatio * cos(radians),
                        y: diameter / 2 - diameter * radiusRatio * sin(radians)
                    )
            }
        }
        .allowsHitTesting(false)
    }
}
