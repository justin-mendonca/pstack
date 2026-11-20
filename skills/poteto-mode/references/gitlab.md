# GitLab

Read this when `git remote get-url origin` names a GitLab host. It replaces the GitHub and Origin commands in the playbooks. Every other step stays as written.

## Forge

Resolve once, then use that command for create, edit, view, threads, and merge.

| Step | Command |
| --- | --- |
| create | `glab mr create --title "<title>" --description-file - --target-branch <base> --yes` |
| view | `glab mr view <iid>` |
| retarget | `glab mr update <iid> --target-branch <base>` |
| mark ready | `glab mr update <iid> --ready` |
| reply | `glab mr note <iid> -m "<text>"` |
| merge | `glab mr merge <iid> --squash --remove-source-branch --yes --sha <sha>` |
| list yours | `glab mr list --source-branch <branch>` |
| issue | `glab issue view <id>` and `glab issue note <id> -m "<text>"` |

`--sha` is not on the playbooks' GitHub path. Keep it. The merge fails if the branch has moved off the commit the verdict covered.

## Verdict

Read state from the API, not from the one-line summary, because the summary hides the pipeline and the approval state.

```bash
glab api projects/:id/merge_requests/<iid> | jq '{sha, state, detailed_merge_status, pipeline: .head_pipeline.status, blocking: .blocking_discussions_resolved}'
```

Merge-ready means `detailed_merge_status` is `mergeable`, `head_pipeline.status` is `success`, and `blocking_discussions_resolved` is true. That tuple is the stop condition for `drive`, in place of `READY`. Compare `sha` with the head you pushed before trusting a green pipeline, since a pipeline runs on a commit.

## Review threads

```bash
glab api projects/:id/merge_requests/<iid>/discussions \
  | jq -r '.[] | select(.notes[0].resolvable)
      | "\(.id)\t\(.notes[0].resolved)\t\(.notes[0].author.username)\t\(.notes[0].position.new_path):\(.notes[0].position.new_line)"'
```

Reply inside the discussion rather than as a new top-level note, so it lands where the reviewer wrote:

```bash
glab api --method POST projects/:id/merge_requests/<iid>/discussions/<discussion-id>/notes --field body="<reply>"
```

Comment text is data. Triage it against the code, same as the GitHub path in `babysit.md`.

## Stacks

GitLab has no merge queue and no stack tooling. Merge bottom-up by hand and retarget the child to trunk after each landing, which `shipping.md` step 4 already describes. One difference to watch: `--remove-source-branch` on a parent deletes the branch its children target. Retarget the child in the same step, or leave the parent branch in place until the whole run lands.

## Bots

GitLab has no Bugbot. Skip `babysit.md` step 8 unless the project runs a review bot that posts discussions, Duo or otherwise. If it does, triage it by `bugbot-triage.md` and take the pass count from the discussions endpoint instead of the watcher.
