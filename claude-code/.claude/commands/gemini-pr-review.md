I want you to ask Gemini AI to do a Github pull request review, on the PR defined in the `<task></task>` element below. If the tag is empty, the first thing you should do is ask me what the PR is.

## Calling Gemini

Use the command line interface with the `-p` flag and Gemini will return it's response to you. Examples:

 - `gemini -p "YOUR PROMPT"`

 - `gemini -p "Review PR #5 and provide feedback using the get_pull_request tool, e.g. get_pull_request (MCP_DOCKER MCP Server) {"pullNumber":5,"owner":"xxxx","repo":"yyyy"} get_pull_request_diff (MCP_DOCKER MCP Server) {"pullNumber":5,"owner":"xxxx","repo":"yyyy"}. There is no need to submit the PR review, just provide the feedback directly."`

Make sure you instruct Gemini to use the `get_pull_request` and `get_pull_request` tools to fetch the PR details, passing in the correct PR number and owner and repo variables.

If Gemini responds with an error about `Quota exceeded for quota metric 'Gemini 2.5 Pro Requests'`, or similar error, it means we can't use that model and need to specify a different model.

Try calling `gemini` again, but this time specify a different model to use, e.g. `gemini -m "gemini-2.5-flash" -p "YOUR PROMPT"`.

## Collaboration

### Step 1
- You should use subagents to:
    - ask Gemini for its initial output for this PR review and present it to me
    - review the feedback from Gemimi for this PR and provide your own comments on what you think about the PR review

### Step 2
- Formulate a response to the PR review based on Gemini's feedback and your own comments and suggestions, and present it to me

<task>$ARGUMENTS</task>
