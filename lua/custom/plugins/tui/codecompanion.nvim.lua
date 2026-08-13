return {
  'olimorris/codecompanion.nvim',
  version = '^19.0.0',
  cmd = { 'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanionCmd' },
  keys = {
    { '<leader>A', '<cmd>CodeCompanionChat Toggle<CR>', desc = 'Agent: Toggle panel' },
    { '<leader>aa', '<cmd>CodeCompanionActions<CR>', desc = 'Agent: Actions' },
    { '<leader>ai', '<cmd>CodeCompanion<CR>', mode = 'v', desc = 'Agent: Inline selection' },
    { '<leader>aA', '<cmd>CodeCompanionChat adapter=anthropic<CR>', desc = 'Agent: Anthropic Claude' },
    { '<leader>aC', '<cmd>CodeCompanionChat adapter=codex<CR>', desc = 'Agent: ChatGPT Codex' },
    { '<leader>aL', '<cmd>CodeCompanionChat adapter=llama_swap<CR>', desc = 'Agent: Local LLM' },
    { '<leader>aG', '<cmd>CodeCompanionChat adapter=copilot<CR>', desc = 'Agent: GitHub Copilot' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    adapters = {
      acp = {
        opts = { show_presets = false },
        codex = function()
          return require('codecompanion.adapters').extend('codex', {
            defaults = {
              auth_method = 'chat-gpt',
            },
            env = {
              CODEX_PATH = '/Users/ejohnson/.local/bin/codex',
            },
          })
        end,
      },
      http = {
        opts = { show_presets = false },
        anthropic = function()
          return require('codecompanion.adapters').extend('anthropic', {
            formatted_name = 'Anthropic Claude',
          })
        end,
        copilot = function()
          return require('codecompanion.adapters').extend('copilot', {
            formatted_name = 'GitHub Copilot',
            -- Copilot's model catalog marks `gpt-4.1` as this account's enabled
            -- chat default. The catalog's `auto` marker is not accepted by the
            -- chat-completions endpoint, so do not send it as a model ID.
            schema = {
              model = {
                default = 'gpt-4.1',
                choices = {
                  ['gpt-4.1'] = {
                    formatted_name = 'GPT-4.1 (Copilot)',
                    opts = { can_stream = true, can_use_tools = true, has_vision = true },
                  },
                },
              },
            },
          })
        end,
        llama_swap = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            formatted_name = 'llama-swap',
            env = {
              api_key = 'TERM',
              url = 'http://127.0.0.1:8090',
              chat_url = '/v1/chat/completions',
              models_endpoint = '/v1/models',
            },
            schema = {
              model = {
                default = 'coder-flash',
                -- `/v1/models` also exposes the embeddings-only service. It cannot
                -- produce chat completions, so deliberately keep it out of this UI.
                choices = {
                  ['coder-flash'] = {
                    formatted_name = 'Coder Flash',
                    meta = { context_window = 65536 },
                  },
                  ['coder-27b'] = {
                    formatted_name = 'Coder 27B',
                    meta = { context_window = 65536 },
                  },
                  ['coder-next'] = {
                    formatted_name = 'Coder Next',
                    meta = { context_window = 16384 },
                  },
                },
              },
            },
          })
        end,
      },
    },
    display = {
      action_palette = {
        provider = 'telescope',
      },
    },
  },
}
