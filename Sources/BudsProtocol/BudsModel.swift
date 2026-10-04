/// Capabilities of a REDMI Buds model, ported from Gadgetbridge's `devices/redmibuds/*Coordinator*`
/// and `AbstractRedmiBudsCoordinator`. Models are resolved from the Bluetooth device name.
public struct BudsModel: Equatable, Sendable {
    public enum Identifier: String, CaseIterable, Sendable {
        case buds3Pro, buds4Active, buds5Pro, buds6, buds6Pro, buds6Active, buds6Lite, buds8, buds8Active, buds8Pro
        /// Unknown "Redmi Buds*" name: only commands confirmed on hardware are offered.
        case generic
    }

    public let id: Identifier
    public let displayName: String
    /// Whether the control channel is opened with the challenge/response handshake (Gadgetbridge).
    public var requiresAuthentication = true
    /// Whether this implementation was verified against real hardware (not just Gadgetbridge's tables).
    public let isTestedOnHardware: Bool

    /// Empty means the model has no noise control.
    public var ambientSoundModes: [AmbientSoundMode] = []
    public var noiseCancellingStrengths: [NoiseCancellingStrength] = []
    public var transparencyStrengths: [TransparencyStrength] = []
    public var supportsAdaptiveNoiseCancelling = false

    public var equalizerPresets: [EqualizerPreset] = []
    public var supportsCustomEqualizer = false
    public var supportsAdaptiveSound = false
    /// Experimental: spatial audio values are unverified (see `SpatialAudioMode`).
    public var supportsSpatialAudio = false

    public var supportsWearingDetection = false
    public var supportsAutoAnswer = false
    public var supportsDoubleConnection = false

    public var supportsFindDevice = false
    public var supportsFindPerEarbud = false

    public var singleTapActions: [GestureAction] = []
    /// Used for double and triple taps.
    public var tapActions: [GestureAction] = []
    public var longPressActions: [LongGestureAction] = []
    public var ambientSoundCycles: [AmbientSoundCycle] = []

    public var hasNoiseControl: Bool { !ambientSoundModes.isEmpty }
    public var hasEqualizer: Bool { !equalizerPresets.isEmpty || supportsCustomEqualizer }
    public var hasGestures: Bool { !singleTapActions.isEmpty || !tapActions.isEmpty || !longPressActions.isEmpty }

    public func supports(tap: TapType) -> Bool { !gestureActions(for: tap).isEmpty }

    /// Raw action codes selectable for the given gesture on this model.
    public func gestureActions(for tap: TapType) -> [UInt8] {
        switch tap {
        case .single: singleTapActions.map(\.rawValue)
        case .double, .triple: tapActions.map(\.rawValue)
        case .long: longPressActions.map(\.rawValue)
        }
    }

    private init(_ id: Identifier, _ displayName: String, tested: Bool = false, configure: (inout BudsModel) -> Void = { _ in }) {
        self.id = id
        self.displayName = displayName
        self.isTestedOnHardware = tested
        configure(&self)
    }

    // MARK: Model table

    private static let allGestureActions: [GestureAction] = GestureAction.allCases
    private static let actionsWithoutNone: [GestureAction] = [.playPause, .previousTrack, .nextTrack, .volumeUp, .volumeDown]

    private static let buds3Pro = BudsModel(.buds3Pro, "Redmi Buds 3 Pro") {
        $0.ambientSoundModes = AmbientSoundMode.allCases
        $0.noiseCancellingStrengths = NoiseCancellingStrength.allCases
        $0.transparencyStrengths = [.regular, .voice]
        $0.equalizerPresets = [.standard, .treble, .bass, .voice]
        $0.tapActions = actionsWithoutNone
        $0.longPressActions = [.voiceAssistant, .ambientSoundControl]
        $0.ambientSoundCycles = AmbientSoundCycle.allCases
        $0.supportsWearingDetection = true
        $0.supportsAutoAnswer = true
        $0.supportsDoubleConnection = true
    }

    private static let buds4Active = BudsModel(.buds4Active, "Redmi Buds 4 Active")

    /// Redmi Buds 5 Pro; Buds 6 and 6 Pro reuse it.
    private static func fivePro(_ id: Identifier, _ name: String) -> BudsModel {
        BudsModel(id, name) {
            $0.ambientSoundModes = AmbientSoundMode.allCases
            $0.noiseCancellingStrengths = [.balanced, .light, .deep]
            $0.transparencyStrengths = TransparencyStrength.allCases
            $0.supportsAdaptiveNoiseCancelling = true
            $0.equalizerPresets = [.standard, .treble, .bass, .voice, .custom]
            $0.supportsCustomEqualizer = true
            $0.supportsAdaptiveSound = true
            $0.singleTapActions = allGestureActions
            $0.tapActions = actionsWithoutNone
            $0.longPressActions = [.voiceAssistant, .ambientSoundControl]
            $0.ambientSoundCycles = AmbientSoundCycle.allCases
            $0.supportsWearingDetection = true
            $0.supportsAutoAnswer = true
            $0.supportsDoubleConnection = true
        }
    }

    private static let buds6Active = BudsModel(.buds6Active, "Redmi Buds 6 Active") {
        $0.equalizerPresets = [.standard, .treble, .bass, .voice, .volume]
        $0.supportsFindDevice = true
        $0.supportsFindPerEarbud = true
        $0.singleTapActions = allGestureActions
        $0.tapActions = actionsWithoutNone
        $0.longPressActions = [.none, .voiceAssistant]
    }

    private static let buds6Lite = BudsModel(.buds6Lite, "Redmi Buds 6 Lite") {
        $0.ambientSoundModes = AmbientSoundMode.allCases
        $0.supportsCustomEqualizer = true
        $0.supportsFindDevice = true
        $0.supportsFindPerEarbud = true
        $0.singleTapActions = allGestureActions
        $0.tapActions = allGestureActions
        $0.longPressActions = [.voiceAssistant, .ambientSoundControl]
        $0.ambientSoundCycles = AmbientSoundCycle.allCases
        $0.supportsAutoAnswer = true
    }

    /// REDMI Buds 8 Active capabilities; the plain Buds 8 builds on them.
    private static func eight(_ id: Identifier, _ name: String, tested: Bool = false,
                              extra: (inout BudsModel) -> Void = { _ in }) -> BudsModel {
        BudsModel(id, name, tested: tested) {
            $0.equalizerPresets = [.balanced, .treble, .bass, .voice, .volume, .custom]
            $0.supportsCustomEqualizer = true
            $0.supportsAdaptiveSound = true
            $0.supportsFindDevice = true
            $0.supportsFindPerEarbud = true
            $0.singleTapActions = allGestureActions
            $0.tapActions = actionsWithoutNone
            $0.longPressActions = [.none, .voiceAssistant]
            $0.supportsDoubleConnection = true
            extra(&$0)
        }
    }

    private static let buds8Active = eight(.buds8Active, "REDMI Buds 8 Active")

    /// Buds 8 Active capabilities with noise control enabled (confirmed on hardware).
    /// The strength lists are provisional: the app only shows a strength picker once the earbuds report a value.
    private static let buds8 = eight(.buds8, "REDMI Buds 8", tested: true) {
        $0.ambientSoundModes = AmbientSoundMode.allCases
        $0.noiseCancellingStrengths = [.balanced, .light, .deep]
        $0.transparencyStrengths = TransparencyStrength.allCases
    }

    /// Not in Gadgetbridge: assumed to be the Buds 8 capability set plus adaptive noise cancelling
    /// (the 5 Pro / 6 Pro toggle) and spatial audio. Untested; the strength pickers only show once the
    /// earbuds report a value. The earbuds never answer the auth challenge, but accept
    /// commands on the "MIWEAR" channel without it (as a working Linux client for this model does).
    private static let buds8Pro = eight(.buds8Pro, "REDMI Buds 8 Pro") {
        $0.requiresAuthentication = false
        $0.ambientSoundModes = AmbientSoundMode.allCases
        $0.noiseCancellingStrengths = [.balanced, .light, .deep]
        $0.transparencyStrengths = TransparencyStrength.allCases
        $0.supportsAdaptiveNoiseCancelling = true
        $0.supportsSpatialAudio = true
    }

    public static let genericFallback = BudsModel(.generic, "REDMI Buds") {
        $0.ambientSoundModes = AmbientSoundMode.allCases
    }

    public static let all: [BudsModel] = [
        buds3Pro, buds4Active, fivePro(.buds5Pro, "Redmi Buds 5 Pro"), fivePro(.buds6, "Redmi Buds 6"),
        fivePro(.buds6Pro, "Redmi Buds 6 Pro"), buds6Active, buds6Lite, buds8, buds8Active, buds8Pro,
    ]

    // MARK: Name resolution

    private static func normalize(_ name: String) -> String {
        name.lowercased().split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    private static let liteKey = "redmi buds 6 lite"
    /// Matched with spaces removed, so "Buds 8 PRO", "buds8 pro" or "REDMI Buds 8 Pro (CN)" all count.
    /// "buds" is required: a bare "8 pro" would also match phones such as "Pixel 8 Pro".
    private static let eightProKey = "buds8pro"

    /// Resolves the most specific model: exact (case-insensitive) name match, "Buds 6 Lite" anywhere in the
    /// name (as Gadgetbridge does), "Buds 8 Pro" anywhere ignoring spaces, otherwise the generic fallback. "REDMI Buds 8" never resolves to
    /// "REDMI Buds 8 Active" or vice versa.
    public static func resolve(name: String) -> BudsModel {
        let key = normalize(name)
        if let exact = all.first(where: { normalize($0.displayName) == key }) { return exact }
        if key.contains(liteKey) { return buds6Lite }
        if key.filter({ !$0.isWhitespace }).contains(eightProKey) { return buds8Pro }
        return genericFallback
    }

    /// True for any device whose name starts with "Redmi Buds" (case-insensitive) or resolves to a known model.
    public static func isRedmiBuds(name: String?) -> Bool {
        guard let name else { return false }
        let key = normalize(name)
        return key == "redmi buds" || key.hasPrefix("redmi buds ") || resolve(name: name).id != .generic
    }
}

public struct DeviceCandidate: Equatable, Sendable {
    public var id: String
    public var name: String
    public var isConnected: Bool

    public init(id: String, name: String, isConnected: Bool) {
        self.id = id
        self.name = name
        self.isConnected = isConnected
    }
}

/// Picks which paired device to control when several REDMI Buds are paired.
public enum DeviceSelection {
    public static func eligible(_ candidates: [DeviceCandidate]) -> [DeviceCandidate] {
        candidates.filter { BudsModel.isRedmiBuds(name: $0.name) }
    }

    /// Explicit user choice first, then a currently connected device, then the first eligible one.
    public static func choose(from candidates: [DeviceCandidate], preferredID: String?) -> DeviceCandidate? {
        let devices = eligible(candidates)
        if let preferredID, let match = devices.first(where: { $0.id == preferredID }) { return match }
        return devices.first(where: \.isConnected) ?? devices.first
    }
}
