vim.api.nvim_create_user_command('Tutor', function()
  -- Manually source the tutor plugin if it's disabled
  vim.opt.rtp:append(vim.fn.stdpath 'data' .. '/site/pack/packer/start/tutor')
  vim.cmd 'runtime! plugin/tutor.vim'
end, {})
