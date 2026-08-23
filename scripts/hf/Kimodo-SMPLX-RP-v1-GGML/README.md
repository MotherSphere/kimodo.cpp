---
license: other
library_name: ggml
base_model: nvidia/Kimodo-SMPLX-RP-v1
base_model_relation: quantized
tags: [gguf, ggml, text-to-motion, smplx, kimodo]
---

# Kimodo-SMPLX-RP-v1-GGML

Native F32 GGML/GGUF conversion of
[nvidia/Kimodo-SMPLX-RP-v1](https://huggingface.co/nvidia/Kimodo-SMPLX-RP-v1),
the SMPL-X 22-joint text-and-constraint conditioned motion diffusion model.
This repository contains only the diffusion model; its reusable Llama-derived
text encoder is distributed separately as
[`Llama-3-Kimodo-GGML`](https://huggingface.co/LocalAI-io/Llama-3-Kimodo-GGML).

From a kimodo.cpp checkout, install both with:

```sh
nix develop path:. --command scripts/download_gguf_weights.sh --output "$PWD"
```

The model is installed at `models/kimodo-smplx-rp-v1-f32.gguf`. Use
`--motion-only` when supplying a precomputed LLM2Vec embedding.

## Provenance and licence

Converted by kimodo.cpp from upstream commit
`1419ba56b734c48bbafb41fefa84088ca94583b5`. `MANIFEST.json` records the
source revision and SHA-256 of the GGUF.

Kimodo-SMPLX-RP-v1 is for non-commercial research use only and remains subject
to the [NVIDIA Internal Scientific Research and Development Model License](https://huggingface.co/nvidia/Kimodo-SMPLX-RP-v1).
This conversion grants no additional rights.
