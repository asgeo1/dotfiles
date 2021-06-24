-- TODO: make work with unsaved buffers
return {
    formatCommand = ([[
        prettier
        ${--config-precedence:configPrecedence}
        ${--tab-width:tabWidth}
        ${--single-quote:singleQuote}
        ${--trailing-comma:trailingComma}
    ]]):gsub(
        "\n",
        ""
    )
}

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
