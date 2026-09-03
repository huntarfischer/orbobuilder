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
    @State private var spring = IrisPaneSpring(position: 0)
    @State private var dragging = false
    @State private var lastY = 0.0
    @State private var lastTime = Date()
    @State private var arcDrag = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var current: LunarCourse { signal.course?.ticket.subject.course ?? .sky }
    private var courses: [LunarCourse] { LunarCourse.allCases.filter { hasNatal || $0 != .natal } }
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                crown.frame(height: 64)
                    .gesture(DragGesture(minimumDistance: 8).onChanged { arcDrag = $0.translation.width }
                        .onEnded { value in
                            let projected = value.predictedEndTranslation.width
                            if abs(projected) > 24, let index = courses.firstIndex(of: current) {
                                course(courses[(index + (projected < 0 ? 1 : courses.count - 1)) % courses.count])
                            }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { arcDrag = 0 }
                        })
                if let fact = signal.reading, let accepted = signal.course {
                    IrisLunarPaneView(reading: fact, accepted: accepted, hasNatal: hasNatal, select: select, dismiss: dismiss)
                } else if let reading = signal.course {
                    IrisLunarCourseView(reading: reading, goToMoment: goToMoment)
                }
            }
            .frame(height: max(140, height * 0.47 - spring.position))
            .background { IrisLunarPaneMaterial() }
            .overlay(alignment: .top) {
                Capsule().fill(IrisAstrolabeStyle.text.opacity(0.55)).frame(width: 38, height: 3)
                    .frame(width: 100, height: 26).contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 3).onChanged { value in
                        let now = value.time
                        if !dragging { dragging = true; lastY = value.translation.height; lastTime = now }
                        let dt = max(0.001, now.timeIntervalSince(lastTime))
                        spring.velocity = (value.translation.height - lastY) / dt
                        spring.position = IrisPaneSpring.rubber(spring.target + value.translation.height, lower: -height * 0.28, upper: height * 0.30)
                        lastY = value.translation.height; lastTime = now
                    }.onEnded { _ in
                        dragging = false
                        let stops = [-height * 0.28, 0, height * 0.30]
                        spring.target = IrisPaneSpring.nearest(spring.position, velocity: spring.velocity, stops: stops)
                        if spring.target > 0 { dismiss(); spring = IrisPaneSpring(position: 0) }
                        else if reduceMotion { spring.position = spring.target; spring.velocity = 0 }
                    })
                    .accessibilityLabel("Raise or lower Lunar Pane")
            }
        }.task {
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(1.0 / 60)) } catch { return }
                if !dragging && (spring.position != spring.target || spring.velocity != 0) { spring.advance(seconds: 1.0 / 60) }
            }
        }
    }
    private var crown: some View {
        GeometryReader { proxy in
            let index = courses.firstIndex(of: current) ?? 0
            ZStack {
                ForEach(-1...1, id: \.self) { offset in
                    let item = courses[(index + offset + courses.count) % courses.count]
                    Button { course(item) } label: {
                        Text(item.title).font(.system(size: 10, weight: .medium)).tracking(1.2)
                            .foregroundStyle(offset == 0 ? IrisAstrolabeStyle.gold : IrisAstrolabeStyle.text.opacity(0.6))
                            .frame(minWidth: 70, minHeight: 36)
                            .overlay(alignment: .bottom) { if offset == 0 { Rectangle().fill(IrisAstrolabeStyle.gold).frame(width: 52, height: 0.7) } }
                    }.buttonStyle(.plain)
                        .rotationEffect(.degrees(Double(offset) * 16 + arcDrag / 10))
                        .position(x: proxy.size.width / 2 + Double(offset) * proxy.size.width * 0.29 + arcDrag * 0.35,
                                  y: offset == 0 ? 36 : 49)
                        .accessibilityIdentifier("orbo.course.\(item.rawValue)")
                }
                Button(action: dismiss) { Image(systemName: "chevron.down").font(.system(size: 10)).frame(width: 30, height: 30) }
                    .foregroundStyle(IrisAstrolabeStyle.text.opacity(0.65))
                    .position(x: proxy.size.width - 24, y: 49)
                    .accessibilityLabel("Lower Lunar Pane").accessibilityIdentifier("orbo.pane.close")
            }
        }
    }
}
