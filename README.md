# Лабораторная работа № 1

Сайт на **MkDocs** с темой Material для заданий T3 и P4. Пакетный менеджер — **uv**.

- [GitHub Pages](https://ansshour.github.io/practice-1-python/)
- [Helios](https://se.ifmo.ru/~s313344/)

## Локальный запуск

Нужен uv 0.12.24 или новее: [инструкция установки](https://docs.astral.sh/uv/getting-started/installation/). Версия Python
указана в `.python-version`; uv установит её при необходимости. Если uv уже
установлен, его можно обновить командой `uv self update`.

```bash
uv sync --locked
uv run mkdocs serve
```

Откройте http://127.0.0.1:8000/. uv создаёт `.venv` и использует его автоматически.
Для работы с активированным окружением можно выполнить `source .venv/bin/activate`.
Отдельные pip и virtualenv этому процессу не нужны.

## Сборка

```bash
uv run --frozen mkdocs build --strict
```

Результат — каталог `dist/`. Предупреждения, включая битые внутренние ссылки
и неверные якоря, останавливают строгую сборку. Прямые зависимости указаны
в `pyproject.toml`, полный набор версий — в `uv.lock`.

Для проверки размещения в подкаталоге:

```bash
SITE_URL=http://127.0.0.1:8000/practice-1/ uv run mkdocs serve
```

Откройте http://127.0.0.1:8000/practice-1/. `SITE_URL` — полный адрес сайта
с конечным `/`. MkDocs формирует пути при `use_directory_urls: true`.

## Публикация

GitHub Actions устанавливает uv и Python, выполняет `uv sync --locked`
и `uv run --frozen mkdocs build --strict`.

- `pages.yml` проверяет push и pull request. Из `main` сайт публикуется
  официальными `upload-pages-artifact` и `deploy-pages`. В Pages выбран Source = GitHub Actions.
- `helios.yml` передаёт `dist/` по SSH/rsync. `main` обновляет основной сайт,
  другие ветки — `previews/branch-<первые 16 символов SHA-256 имени ветки>/`.
- Ручные операции `interrupt` и `rollback` проверяют отказ до переключения
  и возврат предыдущего релиза. Откат запускается из `main`.

Ссылка preview определяется веткой, а не номером PR; отдельного бота комментариев
в PR нет. Алгоритм и устройство релизов описаны в [P4](docs/p4.md).

Переменные окружения `helios`: `HELIOS_HOST`, `HELIOS_USER`, `HELIOS_PORT`, `HELIOS_URL`.
Секреты: `HELIOS_SSH_KEY`, `HELIOS_KNOWN_HOSTS`. Ключи не записываются в Git.

Healthcheck проверяет HTTP 200, контрольную строку `practice-1-site-ready`
на странице `example/`, а на Helios — ещё и ожидаемый `release.txt`.
При неудачном healthcheck автоматического отката нет: он запускается вручную.

## Поиск и формулы

Поиск Material использует локальный индекс на русском и английском.
Формулы обрабатывают `pymdownx.arithmatex` и KaTeX 0.16.22.
JS, CSS и шрифты KaTeX находятся в `docs/assets/katex/`; внешние CDN не нужны.
Системный шрифт сайта отключает загрузку Google Fonts.

## Материалы и лицензии

- [Ход работы](docs/progress.md), [T3](docs/t3.md), [P4](docs/p4.md).
- Код — MIT, авторские тексты — CC BY 4.0.
- KaTeX сохраняет собственную MIT-лицензию в `docs/assets/katex/LICENSE`.
- `report/` и `output/` содержат локальные материалы и исключены из Git.

Документация: [MkDocs](https://www.mkdocs.org/user-guide/configuration/),
[uv в GitHub Actions](https://docs.astral.sh/uv/guides/integration/github/).
