const std = @import("std");
const capy = @import("capy");
const sqlite3 = @import("sqlite3");

pub usingnamespace capy.cross_platform;

pub fn main() !void {
    try capy.backend.init();

    try sqlite3.config(.{ .log = .{ .logFn = sqlite3LogCallback, .userdata = null } });

    const db = try sqlite3.SQLite3.open("hello.db");

    try db.exec(
        \\PRAGMA foreign_keys = ON;
        \\CREATE TABLE IF NOT EXISTS tag(
        \\  id INTEGER PRIMARY KEY AUTOINCREMENT,
        \\  name TEXT NOT NULL
        \\) STRICT;
        \\INSERT OR IGNORE INTO tag(name) VALUES ('text-bubble'), ('clothes');
    , null, null, null);

    var window = try capy.Window.init();
    try window.set(capy.Label(.{ .text = "Hello, World" }));

    window.setTitle("Hello");
    window.resize(250, 100);
    window.show();

    capy.runEventLoop();

    try db.close();
}

fn sqlite3LogCallback(_: ?*anyopaque, err_code: c_int, err_msg: ?[*:0]const u8) callconv(.C) void {
    std.log.scoped(.sqlite3).info("error code = {}, message = {s}", .{ err_code, err_msg orelse "" });
}
