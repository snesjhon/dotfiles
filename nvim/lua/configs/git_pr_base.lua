return function(override)
  local script = vim.env.GIT_PR_BASE_SCRIPT
  if not script or script == "" then
    vim.notify("$GIT_PR_BASE_SCRIPT is not set", vim.log.levels.ERROR)
    return nil
  end

  local base = vim.trim(vim.fn.system({ script, override }))
  if vim.v.shell_error ~= 0 then
    vim.notify(base, vim.log.levels.ERROR)
    return nil
  end
  return base
end
