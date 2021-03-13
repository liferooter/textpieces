/* tools.vala
 *
 * Copyright 2021 Liferooter <glebsmirnov0708@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Textpieces {
    // Define type of tool function
    delegate string ToolFunc(string input, string[] args = {});

    struct Tool {
        public string name;
        public string icon;
        public ToolFunc func;
        public string[] args;
    }

    Tool[] get_tools () {
        return {
            Tool () {
                name = "Hash - SHA1",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA1, s)
            },
            Tool () {
                name = "Hash - SHA256",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA256, s)
            },
            Tool () {
                name = "Hash - SHA384",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA384, s)
            },
            Tool () {
                name = "Hash - SHA512",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.SHA512, s)
            },
            Tool () {
                name = "Hash - MD5",
                icon = "fingerprint2-symbolic",
                func = (s) => Checksum.compute_for_string (ChecksumType.MD5, s)
            },
            Tool () {
                name = "Base64 - Encode",
                icon = "size-right-symbolic",
                func = (s) => Base64.encode (s.data)
            },
            Tool () {
                name = "Base64 - Decode",
                icon = "size-left-symbolic",
                func = (s) => (string) Base64.decode (s)
            },
            Tool () {
                name = "Text - Trim trailing whitespaces",
                icon = "text-symbolic",
                func = (s) => s.strip()
            },
            Tool () {
                name = "Text - Count symbols",
                icon = "text-symbolic",
                func = (s) => s.char_count().to_string(),
                args = {}
            },
            Tool () {
                name = "Text - Count lines",
                icon = "text-symbolic",
                func = (s) => {
                    var counter = 1;
                    for (var i = 0; i < s.length; i++) {
                        if (s[i] == '\n') {
                            counter++;
                        }
                    }
                    return counter.to_string();
                }
            }
        };
    }
}
