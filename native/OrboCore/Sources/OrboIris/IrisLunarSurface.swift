import SwiftUI
import OrboCore

struct IrisLunarSurface: View {
    let signal: LunarPaneSignalFrame
    let hasNatal: Bool
    let height: Double
    let select: (AstrolabeChart.Kind, AstroDNAGene?) -> Void
    let course: (LunarCourse) -> Void
    let dismiss: () -> Void
    let goToMoment: (JulianDay) -> Void
    let availableCourses: [LunarCourse]
    let selectAlmanacBody: (MundaneBody?) -> Void
    @State private var spring = IrisPaneSpring(position: 0)
    @State private var dragging = false
    @State private var lastY = 0.0
    @State private var lastTime = Date()
    @State private var arcDrag = 0.0
    @State private var arcSpring = IrisPaneSpring(position: 0)
    @State private var arcHeld = false
    @State private var arcLastTime = Date()
    @State private var closing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    private var current: LunarCourse { signal.course?.ticket.subject.course ?? .sky }
    private var courses: [LunarCourse] {
        var result = availableCourses.filter { hasNatal || $0 != .natal }
        if !result.contains(current) { result.append(current) }
        return result
    }
    private var peek: Double { height * 0.47 - 32 }
    private var stops: [Double] {
        switch signal.course?.rest ?? .facts {
        case .facts: return [0, peek]
        case .pager: return [-height * 0.28, 0, peek]
        case .raised: return [-height * 0.28, peek]
        }
    }
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                crown.frame(height: 64)
                if signal.course?.arrangement == .railed {
                    ScrollView(.horizontal) {
                        HStack(spacing: 14) {
                            Button("ALL") { selectAlmanacBody(nil) }
                                .foregroundStyle(signal.course?.ticket.subject.body == nil ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.text)
                                .accessibilityIdentifier("orbo.rail.ALL")
                            ForEach(MundaneBody.canonicalOrder, id: \.self) { body in
                                Button(body.displayName) { selectAlmanacBody(body) }
                                    .foregroundStyle(signal.course?.ticket.subject.body?.rawValue == body.displayName ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.text)
                            }
                        }.font(.system(size: 10)).padding(.horizontal, 26).padding(.bottom, 12)
                    }.scrollIndicators(.hidden).tint(IrisAstrolabeStyle.gold)
                }
                if let fact = signal.reading, let accepted = signal.course {
                    IrisLunarPaneView(reading: fact, accepted: accepted, hasNatal: hasNatal, select: select, dismiss: lower)
                } else if let reading = signal.course {
                    IrisLunarCourseView(reading: reading, goToMoment: goToMoment)
                }
            }
            .frame(height: max(32, height * 0.47 - spring.position)).clipped()
            .background { IrisLunarPaneMaterial() }
            .overlay(alignment: .top) {
                Capsule().fill(IrisAstrolabeStyle.text.opacity(0.55)).frame(width: 38, height: 3)
                    .frame(width: 100, height: 26).contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 3).onChanged { value in
                        let now = value.time
                        if !dragging { dragging = true; lastY = value.translation.height; lastTime = now }
                        let dt = max(0.001, now.timeIntervalSince(lastTime))
                        spring.velocity = (value.translation.height - lastY) / dt
                        spring.position = IrisPaneSpring.rubber(spring.target + value.translation.height, lower: stops.first!, upper: peek)
                        lastY = value.translation.height; lastTime = now
                    }.onEnded { _ in
                        dragging = false
                        spring.target = IrisPaneSpring.nearest(spring.position, velocity: spring.velocity, stops: stops)
                        if spring.target == peek { closing = true }
                        else if reduceMotion { spring.position = spring.target; spring.velocity = 0 }
                    })
                    .accessibilityLabel("Raise or lower Lunar Pane")
            }
        }.onAppear { if signal.course?.rest == .raised { spring = IrisPaneSpring(position: -height * 0.28) } }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(1.0 / 60)) } catch { return }
                if !dragging && (spring.position != spring.target || spring.velocity != 0) { spring.advance(seconds: 1.0 / 60) }
                if !arcHeld && (arcSpring.position != arcSpring.target || arcSpring.velocity != 0) {
                    arcSpring.advance(seconds: 1.0 / 60); arcDrag = arcSpring.position
                }
                if closing && abs(spring.position - peek) < 0.5 { dismiss(); return }
            }
        }
    }
    private var crown: some View {
        GeometryReader { proxy in
            let index = courses.firstIndex(of: current) ?? 0
            ZStack {
                ForEach(-1...1, id: \.self) { offset in
                    if offset == 0 || courses.count > 2 || (courses.count == 2 && (index == 0 ? offset == 1 : offset == -1)) {
                    let item = courses[(index + offset + courses.count) % courses.count]
                    let angle = Double(offset) * 16 + arcDrag
                    Button { course(item) } label: {
                        Text(item.title).font(.system(size: 10, weight: .medium)).tracking(1.2)
                            .foregroundStyle(offset == 0 ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.text.opacity(0.6))
                            .frame(minWidth: 70, minHeight: 36)
                            .overlay(alignment: .bottom) { if offset == 0 { Rectangle().fill(IrisAstrolabeStyle.gold).frame(width: 52, height: 0.7) } }
                    }.buttonStyle(.plain)
                        .rotationEffect(.degrees(angle))
                        .position(x: proxy.size.width / 2 + proxy.size.width * 1.05 * sin(angle * .pi / 180),
                                  y: 36 + proxy.size.width * 1.05 * (1 - cos(angle * .pi / 180)))
                        .accessibilityIdentifier("orbo.course.\(item.rawValue)")
                    }
                }
                Button(action: lower) { Image(systemName: "chevron.down").font(.system(size: 10)).frame(width: 30, height: 30) }
                    .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.65))
                    .position(x: proxy.size.width - 24, y: 49)
                    .accessibilityLabel("Lower Lunar Pane").accessibilityIdentifier("orbo.pane.close")
            }.contentShape(Rectangle()).gesture(arcGesture(width: proxy.size.width))
        }
    }
    private func arcGesture(width: Double) -> some Gesture {
        DragGesture(minimumDistance: 8).onChanged { value in
            func angle(_ point: CGPoint) -> Double {
                atan2(point.x - width / 2, width * 1.05 - point.y) * 180 / .pi
            }
            let displacement = angle(value.location) - angle(value.startLocation)
            if arcHeld {
                arcSpring.velocity = (displacement - arcDrag) / max(0.001, value.time.timeIntervalSince(arcLastTime))
            }
            arcHeld = true; arcLastTime = value.time
            arcDrag = displacement; arcSpring.position = displacement
        }.onEnded { _ in
            arcHeld = false
            let detent = IrisPaneSpring.nearest(arcSpring.position, velocity: arcSpring.velocity, stops: [-16, 0, 16])
            let step = -Int(detent / 16)
            if step != 0, let index = courses.firstIndex(of: current) {
                course(courses[(index + step + courses.count) % courses.count])
                arcSpring.position += Double(step) * 16
            }
            arcSpring.target = 0
            if reduceMotion { arcSpring = IrisPaneSpring(position: 0) }
            arcDrag = arcSpring.position
        }
    }
    private func lower() {
        if reduceMotion { dismiss() }
        else { spring.target = peek; closing = true }
    }
}
