// ObjectId.zig

const std = @import("std");

pub const Error = error{
    InvalidLength,
    InvalidCharacter,
};

bytes: [20]u8,

const ObjectId = @This();

pub fn toHex(self: ObjectId) [40]u8 {
    var out: [40]u8 = undefined;
    for (0..20) |idx| {
        const high = (self.bytes[idx]) >> 4;
        const low = self.bytes[idx] & 0x0F;
        out[2 * idx] = byteToHex(high);
        out[2 * idx + 1] = byteToHex(low);
    }
    return out;
}

pub fn fromHex(raw: []const u8) Error!ObjectId {
    if (raw.len != 40) {
        return Error.InvalidLength;
    }
    var id: ObjectId = .{
        .bytes = undefined,
    };
    for (0..20) |idx| {
        const high = try hexToByte(raw[2 * idx]) << 4;
        const low = try hexToByte(raw[2 * idx + 1]);
        id.bytes[idx] = high | low;
    }
    return id;
}

inline fn byteToHex(byte: u8) u8 {
    return "0123456789abcdef"[byte];
}

inline fn hexToByte(hex: u8) Error!u8 {
    if (hex >= '0' and hex <= '9') {
        return hex - '0';
    }
    if (hex >= 'a' and hex <= 'f') {
        return (hex - 'a') + 10;
    }
    if (hex >= 'A' and hex <= 'F') {
        return (hex - 'A') + 10;
    }
    return error.InvalidCharacter;
}

test "hex round trip" {
    const id = try ObjectId.fromHex("2fd4e1c67a2d28fced849ee1bb76e7391b93eb12");
    try std.testing.expectEqualStrings("2fd4e1c67a2d28fced849ee1bb76e7391b93eb12", &id.toHex());

    const id2 = try ObjectId.fromHex("A9993E364706816ABA3E25717850C26C9CD0D89D");
    try std.testing.expectEqualStrings("a9993e364706816aba3e25717850c26c9cd0d89d", &id2.toHex());
}

test "invalid character breaks" {
    const idResult = ObjectId.fromHex("2fd4e1c67a2d28fced849ee1bb76e7391b93eb1G");
    try std.testing.expectError(Error.InvalidCharacter, idResult);
}

test "over 40 characters fail" {
    const idResult = ObjectId.fromHex("2fd4e1c67a2d28fced849ee1bb76e7391b93eb125");
    try std.testing.expectError(Error.InvalidLength, idResult);
}

test "less than 40 characters also fail" {
    const idResult = ObjectId.fromHex("2fd4e1c67a2d28fced849ee1bb76e7391b93eb1");
    try std.testing.expectError(Error.InvalidLength, idResult);
}
