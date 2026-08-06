# htmxr

## Commandes courantes

| Raccourci | Tâche | Commande |
|-----------|-------|----------|
| `/check` | Vérifier le package | `R -e "devtools::check()"` |
| `/test` | Lancer les tests | `R -e "devtools::test()"` |
| `/document` | Mettre à jour la doc | `R -e "devtools::document()"` |
| `/attach` | Mettre à jour le package | `R -e "attachment::att_amend_desc()"` |
| `/site` | Construire le site pkgdown | `R -e "pkgdown::build_site()"` |
| `/format` | Formater le code | `air format .` |

## Agents

| Raccourci | Rôle | Quand l'invoquer |
|-----------|------|-----------------|
| `/htmx-expert` | Revue fidélité et idiomaticité htmx | Nouvelle primitive créée ou modifiée |
| `/shiny-ergonomie` | Regard dev Shiny sur l'intuitivité | Travail sur nommage ou documentation |
| `/shiny-cas-usage` | Couverture fonctionnelle par cas d'usage | Alimenter la roadmap |
| `/plumber2-expert` | Recherche docs et source plumber2 (lookup obligatoire) | Toute question plumber2, **avant** toute affirmation "ça n'existe pas" |

## Suivi de l'écosystème

Consulter `../hyperverse.md` (à la racine de `hyperverse-r/`) en début de session — état et roadmap de tous les packages hyperverse, partagé entre tous les repos. Mettre à jour ce fichier au fil des échanges.

## Contexte du projet

`htmxr` est un package R qui fournit des primitives pour construire des applications web avec htmx et plumber2. Il est agnostique CSS — il ne dépend d'aucun framework CSS particulier.

## Stack technique

- **R** avec conventions tidyverse
- **plumber2** comme serveur HTTP (pas plumber v1)
- **htmx** pour les interactions client
- **htmltools** pour la génération HTML
- **roxygen2** pour la documentation

## Architecture du package

```
htmxr/
├── R/
│   ├── hx_attrs.R          # hx_attrs() — helper interne hx-* attributes
│   ├── hx_example.R        # hx_run_example() — lance un exemple
│   ├── hx_page.R           # hx_page(), hx_head() — page HTML complète
│   ├── hx_serve_assets.R   # hx_serve_assets() — assets statiques
│   ├── hx_slider_input.R   # hx_slider_input() — <input type="range">
│   └── reexports.R         # réexports htmltools
├── inst/
│   ├── assets/
│   │   └── htmx/
│   │       └── 2.0.8/
│   │           └── htmx.min.js
│   └── examples/
│       └── hello/
│           └── api.R
├── man/
├── DESCRIPTION
└── NAMESPACE
```

## Exemples

Les exemples disponibles se trouvent dans `inst/examples/`. Chaque sous-dossier
contient un fichier `api.R` exécutable via `hx_run_example("<nom>")`.

Les exemples existants sont une bonne source d'inspiration pour comprendre
comment combiner les primitives htmxr. Consulter ce dossier avant de demander
des exemples ou de l'aide.

### Convention de nommage

Les dossiers d'exemples sont nommés selon le **concept pédagogique** démontré,
pas selon le dataset ou le domaine métier utilisé.

- ✅ `select-input` — démontre `hx_select_input()` + filtrage dynamique
- ✅ `lazy-load` — démontre le pattern tbody vide chargé au `trigger="load"`
- ❌ `diamonds-explorer` — nom de usecase, pas de concept

## Décisions techniques importantes

### Conventions de nommage

- Fonctions préfixées `hx_` — pas `htmxr_`. Cette convention s'applique à
  toutes les fonctions exportées sans exception, y compris les helpers et les
  wrappers (ex : `hx_is_htmx()`, pas `htmxr_is_htmx()`).
- Ordre des paramètres des composants : `id` toujours en premier et **obligatoire**,
  `label = NULL` en deuxième. Cohérent avec Shiny (`inputId` en premier) et entre
  toutes les fonctions `hx_*` (ex : `hx_button(id, label = NULL)`,
  `hx_select_input(id, label = NULL, choices)`).
- Paramètres htmx : `get`, `post`, `target`, `swap`, `trigger`, `indicator`, `swap_oob`, `confirm`
- Pas de `paste0()` pour construire du HTML — utiliser `htmltools::tags`
- Dans les routes plumber2, le paramètre réponse **doit** s'appeler `response` et le paramètre requête `request` — ce sont les seuls noms reconnus pour l'injection automatique (documenté dans la vignette plumber2 "routing-and-input")


## Règles générales

- Toujours lire la documentation avant de proposer une solution
- Tester les fonctions dans la console R avant de les proposer
- Ne pas affirmer quelque chose sans l'avoir vérifié
- Le package est CSS agnostique — ne pas imposer Bootstrap ou Tailwind
