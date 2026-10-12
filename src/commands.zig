const std = @import("std");

const Failure = std.Io.Writer.Error || std.mem.Allocator.Error;

pub const Handler = *const fn (
    args: []const [:0]const u8,
    allocator: std.mem.Allocator,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) Failure!u8;

pub const unknownOptionErrorCode = 129;
pub const unknownCommandErrorCode = 1;

const zitCmdOptions = struct {
    version: bool = false,
    help: bool = false,
};

pub fn zitCmd(
    args: []const [:0]const u8,
    allocator: std.mem.Allocator,
    stdout: *std.Io.Writer,
    stderr: *std.Io.Writer,
) Failure!u8 {
    var opts: zitCmdOptions = .{};
    for (args, 0..) |arg, idx| {
        if (zitSubcommandsMap.get(arg)) |handler| {
            return handler(args[idx + 1 ..], allocator, stdout, stderr);
        }
        if (std.mem.eql(u8, arg, "--version")) {
            opts.version = true;
            continue;
        }
        if (std.mem.eql(u8, arg, "--help")) {
            opts.help = true;
            continue;
        }
        // error
        if (std.mem.startsWith(u8, arg, "-")) {
            try printUnknownOption(stderr, arg);
            return unknownOptionErrorCode;
        }
        try printUnknownCommand(stderr, arg);
        return unknownCommandErrorCode;
    }
    if (opts.help) {
        return zitHelpCmd(args, allocator, stdout, stderr);
    }
    if (opts.version) {
        return zitVersionCmd(args, allocator, stdout, stderr);
    }
    try printZitUsage(stdout);
    return unknownCommandErrorCode;
}

const zitSubcommandsMap = std.StaticStringMap(Handler).initComptime(.{
    .{ "version", zitVersionCmd },
});

pub fn zitVersionCmd(
    _: []const [:0]const u8,
    _: std.mem.Allocator,
    stdout: *std.Io.Writer,
    _: *std.Io.Writer,
) Failure!u8 {
    try stdout.print("zit version {s}\n", .{"0.0.0"});
    return 0;
}

pub fn zitHelpCmd(
    _: []const [:0]const u8,
    _: std.mem.Allocator,
    stdout: *std.Io.Writer,
    _: *std.Io.Writer,
) Failure!u8 {
    try printZitUsage(stdout);
    return 0;
}

fn printZitUsage(
    writer: *std.Io.Writer,
) Failure!void {
    try writer.print("usage: zit [--version] [--help] <command> [<args>]\n", .{});
}

fn printUnknownOption(stderr: *std.Io.Writer, arg: [:0]const u8) Failure!void {
    try stderr.print("unknown option: {s}\n", .{arg});
}

fn printUnknownCommand(stderr: *std.Io.Writer, arg: [:0]const u8) Failure!void {
    try stderr.print("zit: '{s}' is not a zit command. See 'zit --help'.\n", .{arg});
}
