import Foundation

/// This is the element for a build target that according to Xcode is an "External Build System". You can use this target to run a script.
final public class PBXLegacyTarget: PBXTarget {
    /// Path to the build tool that is invoked (required)
    public var buildToolPath: String?
    
    /// Build arguments to be passed to the build tool.
    public var buildArgumentsString: String?
    
    /// Whether or not to pass Xcode build settings as environment variables down to the tool when invoked
    public var passBuildSettingsInEnvironment: Bool
    
    /// The directory where the build tool will be invoked during a build
    public var buildWorkingDirectory: String?
    
    public init(reference: String,
                name: String,
                buildToolPath: String? = nil,
                buildArgumentsString: String? = nil,
                passBuildSettingsInEnvironment: Bool = false,
                buildWorkingDirectory: String? = nil,
                buildConfigurationList: String? = nil,
                buildPhases: [String] = [],
                buildRules: [String] = [],
                dependencies: [String] = [],
                productName: String? = nil,
                productReference: String? = nil,
                productType: PBXProductType? = nil) {
        self.buildToolPath = buildToolPath
        self.buildArgumentsString = buildArgumentsString
        self.passBuildSettingsInEnvironment = passBuildSettingsInEnvironment
        self.buildWorkingDirectory = buildWorkingDirectory
        super.init(reference: reference,
                   name: name,
                   buildConfigurationList: buildConfigurationList,
                   buildPhases: buildPhases,
                   buildRules: buildRules,
                   dependencies: dependencies,
                   productName: productName,
                   productReference: productReference,
                   productType: productType)
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case buildToolPath
        case buildArgumentsString
        case passBuildSettingsInEnvironment
        case buildWorkingDirectory
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.buildToolPath = try container.decodeIfPresent(.buildToolPath)
        self.buildArgumentsString = try container.decodeIfPresent(.buildArgumentsString)
        let passBuildSettingsInEnvironmentString: String? = try container.decodeIfPresent(.passBuildSettingsInEnvironment)
        self.passBuildSettingsInEnvironment = passBuildSettingsInEnvironmentString.flatMap(Int.init).map { $0 == 1 } ?? false
        self.buildWorkingDirectory = try container.decodeIfPresent(.buildWorkingDirectory)
        try super.init(from: decoder)
    }
    
    public static func == (lhs: PBXLegacyTarget,
                           rhs: PBXLegacyTarget) -> Bool {
        return (lhs as PBXTarget) == (rhs as PBXTarget) &&
            lhs.buildToolPath == rhs.buildToolPath &&
            lhs.buildArgumentsString == rhs.buildArgumentsString &&
            lhs.passBuildSettingsInEnvironment == rhs.passBuildSettingsInEnvironment &&
            lhs.buildWorkingDirectory == rhs.buildWorkingDirectory
    }
    
    override func plistValues(proj: PBXProj, isa: String) -> (key: CommentedString, value: PlistValue) {
        let (key, value) = super.plistValues(proj: proj, isa: PBXLegacyTarget.isa)
        var dict: [CommentedString: PlistValue]!
        switch value {
        case let .dictionary(_dict):
            dict = _dict
            if let buildToolPath = buildToolPath {
                dict["buildToolPath"] = PlistValue.string(CommentedString(buildToolPath))
            }
            if let buildArgumentsString = buildArgumentsString {
                dict["buildArgumentsString"] =
                    PlistValue.string(CommentedString(buildArgumentsString))
            }
            dict["passBuildSettingsInEnvironment"] =
                PlistValue.string(passBuildSettingsInEnvironment ? "1" : "0")
            if let buildWorkingDirectory = buildWorkingDirectory {
                dict["buildWorkingDirectory"] =
                    PlistValue.string(CommentedString(buildWorkingDirectory))
            }
        default:
            fatalError("Expected super to give a dictionary")
        }
        return (key: key, value: .dictionary(dict))
    }

}

// MARK: - PBXNativeTarget Extension (PlistSerializable)

extension PBXLegacyTarget: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        return plistValues(proj: proj, isa: PBXLegacyTarget.isa)
    }
    
}
