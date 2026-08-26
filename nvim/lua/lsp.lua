vim.lsp.config("vtsls", {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "all" },
        variableTypes = { enabled = true },
      },
    },
    javascript = {
      inlayHints = { parameterNames = { enabled = "all" } },
    },
  },
})

vim.lsp.enable("vtsls")

Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buf) vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end)

vim.diagnostic.config({ virtual_text = { spacing = 2, prefix = "●" } })

-- Java (jdtls) ----------------------------------------------------------
-- `jdtls` is Homebrew-managed and expected on $PATH; its wrapper already
-- derives a per-project `-data` workspace dir, so none is passed here.
vim.lsp.config("jdtls", {
  cmd = {
    "jdtls",
    -- jdtls's own JVM selection otherwise falls back to whatever `java`/$JAVA_HOME is ambient
    -- on $PATH, which isn't consistent across shells/sessions -- observed launching under
    -- Homebrew's openjdk 26 instead of this mise-managed JDK 25. Since the Gradle daemon
    -- inherits "current java home" from jdtls's own JVM, that mismatch alone was enough to
    -- fail settings.gradle.kts's `must be run with java 25` check on the whole import. Pin
    -- explicitly instead of relying on ambient resolution.
    "--java-executable=/Users/jsalazar/.local/share/mise/http-tarballs/85503144cf864b54c9125c2d5bebb096e206b8d881f6d5043d4dc846b7e22ae5/bin/java",
    "--jvm-arg=-XX:+UseParallelGC",
    "--jvm-arg=-XX:GCTimeRatio=4",
    "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
    "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
    "--jvm-arg=-Xmx4G",
    "--jvm-arg=-Xms100m",
    "--jvm-arg=-Xlog:disable",
  },
  filetypes = { "java" },
  -- settings.gradle(.kts) must win over build.gradle(.kts): every subproject has its own
  -- build.gradle.kts, so searching that marker first stops at the nearest module instead of
  -- climbing to the actual multi-project root, and jdtls ends up importing e.g.
  -- Platform/designer standalone instead of the whole build.
  root_markers = { "settings.gradle", "settings.gradle.kts", "pom.xml", "build.gradle", "build.gradle.kts", ".git" },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  -- Neovim's own VimLeavePre handler waits (synchronously, no polling interval) for jdtls to
  -- close its RPC channel before quitting; with the default `exit_timeout = false` there's no
  -- fallback force-stop, so if jdtls is still busy (mid Gradle sync, or working through a slow
  -- request queued ahead of the shutdown request) Nvim hangs on quit indefinitely. A numeric
  -- exit_timeout force-stops it after this many ms instead of waiting forever.
  exit_timeout = 3000,
  settings = {
    java = {
      server = { launchMode = "Standard" },
      import = {
        gradle = {
          jvmArguments = "-Xmx3g -Xms512m",
          annotationProcessing = { enabled = false },
          -- The project's nexus-hosted wrapper (Gradle 9.4.0 / Kotlin 2.3.0, needed for the
          -- `JvmTarget.JVM_25` reference in build-logic/java-convention) isn't consistently
          -- honored by Buildship for every import phase -- it's been observed falling back to
          -- a bundled Gradle 8.9, which can't parse that build script. Pin directly at the
          -- already-extracted local copy of the same distro instead of relying on the wrapper.
          wrapper = { enabled = false },
          home = "/Users/jsalazar/.gradle/wrapper/dists/gradle-9.4.0-all/anruhsiep7hy403aoddj90ll1/gradle-9.4.0",
          -- With the wrapper disabled there's no strict version pin forcing a matching Gradle
          -- daemon, so it resolves to "current java home" -- i.e. whatever JVM jdtls itself
          -- launched under (see --java-executable above; without that pin this used to resolve
          -- inconsistently and could fail settings.gradle.kts's `must be run with java 25`
          -- check). Neither `java.import.gradle.java.home` nor a literal
          -- `-Dorg.gradle.java.home=...` arg here actually got that JVM used -- only fixing it
          -- at the source, above, worked.
          -- TODO: dotfiles/gradle/fix-buildship-compileonly.init.gradle.kts (the same init
          -- script the coc-java setup applies) would fix two real, separate Buildship bugs here
          -- too -- it drops compileOnly *project* dependencies (gradle/gradle#32284,
          -- eclipse-buildship/buildship#939) and has no Kotlin support at all, so Java files in
          -- mixed Kotlin/Java modules like Platform/designer never resolve Java-from-Kotlin
          -- references. Tried wiring it in via `arguments = {"--init-script", ...}`, but its own
          -- Gradle invocation doesn't inherit the JVM jdtls launched under and fails
          -- settings.gradle.kts's `must be run with java 25` check -- fatally, regressing the
          -- whole import back to a single fallback project, not just this init-script's own
          -- step. Setting `java.home` alongside it didn't fix that either. Reverted for now;
          -- revisit once there's a way to pin the JVM for this specific sub-invocation.
        },
      },
      compile = { nullAnalysis = { mode = "automatic" } },
    },
  },
})

vim.lsp.enable("jdtls")

-- :await instead of :wait -- :wait blocks the UI thread for the whole install (can be
-- minutes on first run), and while blocked it still pumps the event/redraw loop, which can
-- re-enter into other autocmds (e.g. the tabline redraw or zen-mode's quit handling) and
-- livelock. :await runs the install in the background with no blocking at all.
require("nvim-treesitter").install({ "java" }):await(function(err)
  if err then
    vim.notify("nvim-treesitter: java parser install failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function(ev) vim.treesitter.start(ev.buf) end,
  })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "java" then vim.treesitter.start(buf) end
  end
end)
