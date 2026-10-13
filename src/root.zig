//! By convention, root.zig is the root source file when making a package.

pub const ObjectId = @import("ObjectId.zig");

test {
    _ = ObjectId;
}
