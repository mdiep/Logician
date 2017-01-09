import PackageDescription

let package = Package(
    name: "Logician",
    targets: [
        Target(name: "LogicianTests", dependencies: [.Target(name: "Logician")])
    ]
)
