#!/usr/bin/env python3

# Apply the diff from Fairfax to polifax.kbitx to create polifax-full.kbitx
# - modification and insertion are applied,
# - but deleted lines are ignored.

from difflib import SequenceMatcher

with open("fairfax/Fairfax.kbitx") as f:
    a = f.readlines()

with open("polifax.kbitx") as f:
    b = f.readlines()

matcher = SequenceMatcher(None, a, b)

result = []

for tag, i1, i2, j1, j2 in matcher.get_opcodes():
    if tag == "equal":
        result.extend(a[i1:i2])

    elif tag == "replace":
        # use modified text from B
        result.extend(b[j1:j2])

    elif tag == "delete":
        # keep original text from A
        result.extend(a[i1:i2])

    elif tag == "insert":
        # include insertions from B
        result.extend(b[j1:j2])

with open("build/polifax-full.kbitx", "w") as f:
    f.writelines(result)
