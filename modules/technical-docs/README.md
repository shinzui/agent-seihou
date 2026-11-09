# technical-docs

Generates agent skills for writing technical documentation. An entry skill works out what kind of document a reader needs, and five form skills each write one kind well. Documents follow the Diátaxis framework by default and can step outside it when a project's needs call for that.

The generated skills, by default name:

- `tech-docs` classifies the reader's need, plans sets of pages, and hands off to a form skill.
- `tech-docs-tutorial` writes lessons that teach a newcomer by having them build something.
- `tech-docs-how-to` writes goal-oriented guides and quickstarts.
- `tech-docs-reference` writes dry, complete technical description.
- `tech-docs-explanation` writes discussions of why something works the way it does.
- `tech-docs-walkthrough` writes guided readings of real source code, linked from the document they augment.

Install and apply from the consuming project's root:

```sh
seihou install https://github.com/shinzui/agent-seihou.git --module technical-docs
seihou run technical-docs
```

Variables, generation steps, and dependencies are documented in the generated **[technical-docs reference](../../okf-docs/modules/technical-docs.md)**. Change `module.dhall` and regenerate rather than documenting those details here.
