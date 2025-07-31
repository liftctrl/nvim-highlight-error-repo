# Neovim Treesitter 'Invalid end_col' Error Reproduction

This repository demonstrates a reproducible bug in Neovim's Treesitter highlighter, where deleting lines in files with many lines causes an `Invalid 'end_col': out of range` error.

## 🐛 Bug Description

When editing a Markdown file with **256 or more lines**, deleting a line near the end (e.g., line 256) can trigger the following error:

```bash
Error in decoration provider "line" (ns=nvim.treesitter.highlighter):
Error executing lua: /usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:370: Invalid 'end_col': out of range
stack traceback:
        [C]: in function 'nvim_buf_set_extmark'
        /usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:370: in function 'fn'
        /usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:232: in function 'for_each_highlight_state'
        /usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:322: in function 'on_line_impl'
        /usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:411: in function </usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:405
>
```


This error occurs inside the Treesitter decoration provider when `nvim_buf_set_extmark()` is called with an invalid `end_col`.

## ✅ Reproduction Steps

1. **Download the official Neovim tar.gz release** from:  
   👉 https://github.com/neovim/neovim/releases/tag/v0.11.3  
   (e.g., `nvim-linux-x86_64.tar.gz`)

   ```bash
   wget https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz
   ```

2. **Extract the archive**:

   ```bash
   tar xvf  nvim-linux-x86_64.tar.gz 
   ```

3. **Clone this repository and copy the configuration**:
   
   ```bash
   git clone https://github.com/liftctrl/nvim-highlight-error-repo.git
   cp -r nvim-highlight-error-repo/nvim ~/.config/
   ```

4. **Launch Neovim with the test file**:

   ```bash
   ./nvim-linux-x86_64/bin/nvim nvim-highlight-error-repo/test.md
   ```

5. In Neovim, go to **line 256** in `test.md`.

6. In **Insert mode**, press **Backspace** at the beginning of the line to merge it with line 255.

7. Neovim should throw the error shown above.

## 📁 Files in this Repository

- `test.md` — 256 identical Markdown list items used to trigger the bug.

- `nvim/` — A minimal Neovim config folder to enable Treesitter highlighting.

- `fix-snippet.lua` — The Lua snippet used for patching the issue manually.

- `README.md` — This file.

## 🧪 Environment

- OS: Arch Linux (kernel 6.15.8-arch1-2)

- Neovim: v0.11.3 (official tar.gz release, extracted)

## 🛠️ Fix Snippet

To prevent the error, clamp `end_row` and `end_col` to valid values before calling `nvim_buf_set_extmark()`:

```lua
-- Clamp end_row and end_col to valid values
local total_lines = vim.api.nvim_buf_line_count(buf)

if end_row >= total_lines then
  end_row = total_lines - 1
end

local line_text = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, true)[1] or ""
local max_col = #line_text

if end_col > max_col then
  end_col = max_col
end
```

📝 This snippet was tested by placing it before the call to set_extmark() in:

```bash
/usr/share/nvim/runtime/lua/vim/treesitter/highlighter.lua
```


## 📌 Notes

- This repository is intended to help reproduce and verify the issue before submitting an upstream PR to [neovim/neovim](https://github.com/neovim/neovim).
- The provided config in `nvim/` ensures Treesitter is enabled for reproduction.
- Related issue: [neovim/neovim#29550](https://github.com/neovim/neovim/issues/29550)
