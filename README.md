## Outline

**llama-swap-config.yaml**
llama-swap model configuration

**local.llama-swap.plist**
llama-swap background service configuration

**opencode-config.jsonc**
opencode configuration for remote machines utilizing local llama-swap server

## Hardware
This setup is tested and running on M4 Pro 24GB. YMMV with other hardware or configurations.

## Replication

1. Install llama.cpp and llama-swap. For this setup, homebrew was used on an M4 Pro Mac Mini.
2. Download local models via `llama-server`. Exit process when the model is downloaded.
	- e.g. `llama-server -hf ggml-org/gpt-oss-20b-GGUF --port 9999`
3. (for persistence) Add llama-swap *.plist file to LaunchAgents and configure with launchctl. macOS example:
	- `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.llama-swap.plist`
	- `launchctl kickstart -k gui/$(id -u)/local.llama-swap`
	- `launchctl print gui/$(id -u)/local.llama-swap`
4. Add llama-swap configuraton. Ensure path matches `--config` parameter in *.plist file.
5. (if using opencode) Add opencode configuration to local opencode configuration path. Adjust models/server. Default configuration exposes llama-swap on *:8081.
6. (if using cyclical development) Add `AGENTS.md` to opencode configuration directory `~/.config/opencode/AGENTS.md`
7. (if using cyclical development) Add `agents-loop.sh` executable to global PATH for opencode.
	- `/loop {task}` runs the full cyclical agent loop (scout -> implement -> review -> repeat if necessary)
	- `/scout {task}` only runs the investigation portion
	- `/implement` implements the findings from a previous scout task
	- `/review` runs QA on a previous implementation task

## Swapping
llama-swap is utilized to allow for complex tasks within the constraints of the 24gb memory. Swapping roles are outlined below:

| Role | Alias | Model | Notes |
| ---- | ----- | ----- | ----- |
| Investigation | scout | Qwen3.5 9B (Q8) | ~~~ |
| QA/Planning | reviewer | gpt-oss-20b | ~~~ |
| Implementation | coder | Qwen3.8 27B (UD-Q4_K_M) | ~~~ |

