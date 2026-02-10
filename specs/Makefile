# SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
#
# SPDX-License-Identifier: MIT OR Apache-2.0 WITH LLVM-exception

URL="https://raw.githubusercontent.com/ollama/ollama/refs/heads/main/docs/openapi.yaml"

fetch:
		curl -L $(URL) | yq -j |\
		jq --from-file fix.jq |\
		sed -e 's@#/components/schemas@#/definitions@g' \
		> schema-orig.json

generate:
		gen_json --header-file header.adt --root-package Ollama_API.Types schema.json > /tmp/all.txt
		gnatchop /tmp/all.txt ../source/generated
		gnatformat -P ../gnat/ollama_api.gpr ../source/generated/*.ad[sb]
