-- TODO: make prettier work with unsaved buffers / stdin
return {
  formatCommand = ([[
    prettier
    ${--config-precedence:configPrecedence}
    ${--parser:parser}
    ${--tab-width:tabWidth}
    ${--single-quote:singleQuote}
    ${--trailing-comma:trailingComma}
    --stdin-filepath ${INPUT}
  ]]):gsub(
    "\n",
    ""
  ),
  formatStdin = true
}

-- return {
--     formatCommand = "prettier ${--parser:parser} ${--tab-width:tabWidth} ${--single-quote:singleQuote} ${--trailing-comma:trailingComma} ${--config-precedence:configPrecedence} --stdin-filepath ${INPUT}",
--     formatStdin = true
-- }

-- return {
--     formatCommand = ([[
--         prettier
--         ${--config-precedence:configPrecedence}
--         ${--parser:parser}
--         ${--tab-width:tabWidth}
--         ${--single-quote:singleQuote}
--         ${--trailing-comma:trailingComma}
--     ]]):gsub(
--         "\n",
--         ""
--     )
-- }

-- return {
--     formatCommand = "prettier ${--parser:parser} ${--tab-width:tabWidth} ${--single-quote:singleQuote} ${--trailing-comma:trailingComma}",
--     formatStdin = true
-- }

-- return {
--     formatCommand = ([[
--         prettier
--         --stdin-filepath ${INPUT}
--         ${--config-precedence:configPrecedence}
--         ${--tab-width:tabWidth}
--         ${--single-quote:singleQuote}
--         ${--trailing-comma:trailingComma}
--     ]]):gsub(
--         "\n",
--         ""
--     ),
--     formatStdin = true
-- }
