I want you to collaborate with the Gemini AI on the task defined in the `<task></task>` element below. If the tag is empty, the first thing you should do is ask me what the task is.

## Calling Gemini

Use the command line interface with the `-p` flag and Gemini will return it's response to you, eg `gemini -p "YOUR PROMPT"`

Gemini will have no context, so you will need to provide it everything it needs to know about the problem. If you want it to know about files, give it the full path to the file instead of the file contents. Same for directories.

Note that you can use `read-many-files path/to/dir/**/*.rs` i.e. with a glob pattern to read multiple files at once, which is very useful for loading Gemini's context with an entire project.

In most cases I want you to pass the task to Gemini verbatim. Gemini is capable of using it's own MCP tools, so no need for you to run the same MCP tools first yourself and send it the output. Return any output from Gemini, but then also integrate it into your own response.

If Gemini responds with an error about `Quota exceeded for quota metric 'Gemini 2.5 Pro Requests'`, or similar error, it means we can't use that model and need to specify a different model.

Try calling `gemini` again, but this time specify a different model to use, e.g. `gemini -m "gemini-2.5-flash" -p "YOUR PROMPT"`.

## Collaboration

### Step 1
- You should use subagents to:
    - create your initial output for this task
    - ask Gemini for its initial output for this task

### Step 2
- You should then integrate Gemini's answer into your own
    - Look at Gemini's response for anything that you may have missed

### Step 3
- Tell Gemini the task and context again, but this time ask it to critique your response, passing it your response
- Integrate Gemini's suggestions into your own response

<task>$ARGUMENTS</task>
