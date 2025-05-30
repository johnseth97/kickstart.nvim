return {
  'ellisonleao/dotenv.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    require('dotenv').setup {
      enable_on_load = false, -- will load your .env file upon loading a buffer
      verbose = false, -- show error notification if .env file is not found and if .env is loaded
      file_name = '.env.nvim', -- will override the default file name '.env'
    }
  end,
}
