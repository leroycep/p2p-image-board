const std = @import("std");
const packages = @import("@packages");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const sqlite_dep = b.dependency("sqlite3", .{});
    const capy_dep = b.dependency("capy", .{});

    const exe = b.addExecutable("p2p-booru", "src/main.zig");
    exe.addPackagePath("sqlite3", b.pathJoin(&.{ @import("root").dependencies.build_root.sqlite3, "src/sqlite3.zig" }));
    exe.linkLibrary(sqlite_dep.artifact("sqlite3"));
    exe.addPackage(capy);
    exe.linkLibrary(capy_dep.artifact("capy"));

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

pub const capy = std.build.Pkg{
    .name = "capy",
    .source = std.build.FileSource{ .path = @import("root").dependencies.imports.capy.thisDir() ++ "src/main.zig" },
    .dependencies = &.{zigimg},
};

const zigimg = std.build.Pkg{
    .name = "zigimg",
    .source = std.build.FileSource{ .path = @import("root").dependencies.build_root.@"capy.zigimg" ++ "/zigimg.zig" },
};
