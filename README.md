# Claude YouTube Insight Pipeline

YouTube 영상의 자막을 추출하고, Claude Code가 AI 분석을 통해 구조화된 인사이트 노트를 Obsidian 볼트에 자동 저장합니다.

## 기능

```
/youtube https://www.youtube.com/watch?v=VIDEO_ID
```

한 줄 명령으로:
1. YouTube 자막 추출 (한/영/일 자동 감지)
2. 7개 섹션 인사이트 분석 (핵심 요약, 인사이트, 상세 노트, 액션 아이템, 인용구, 비판적 시각)
3. Obsidian 노트로 자동 저장 (카테고리 자동 분류)

## 설치 (3분)

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code) 설치 완료
- Python 3.10+
- Obsidian 볼트 (경로를 알고 있어야 함)

### Windows

```powershell
git clone https://github.com/byeongsopark/claude-youtube-insight.git
cd claude-youtube-insight
powershell -ExecutionPolicy Bypass -File setup.ps1
```

### macOS / Linux

```bash
git clone https://github.com/byeongsopark/claude-youtube-insight.git
cd claude-youtube-insight
chmod +x setup.sh
./setup.sh
```

### 셋업이 하는 일

셋업 스크립트를 실행하면 자동으로 아래 5단계가 진행됩니다:

```
[1/5] Creating directories      → ~/.claude/ 하위 폴더 생성
[2/5] Copying files              → 커맨드, 스크립트, 스킬 파일 7개 복사
[3/5] Installing dependency      → youtube-transcript-api pip 설치
[4/5] Configuring vault path     → ⭐ Obsidian 볼트 경로 입력 (데스크탑마다 다름)
[5/5] Creating category folders  → 볼트 안에 YouTube 카테고리 폴더 6개 자동 생성
```

**Step 4**에서 Obsidian 볼트의 루트 경로를 입력합니다:

```
  Obsidian vault path is required.
  This is the root folder of your Obsidian vault.

  Examples:
    C:\Users\you\Documents\MyVault       (Windows)
    /Users/you/Documents/MyVault         (macOS)
    /home/you/Obsidian/Notes             (Linux)

  Enter vault path: _
```

입력한 경로는 `~/.claude/settings/youtube-vault-path.txt`에 저장되며, `/youtube` 커맨드 실행 시 이 경로를 참조합니다.

> **볼트 경로를 나중에 변경하려면?** setup 스크립트를 다시 실행하면 됩니다.

### 설치 확인

셋업이 끝나면 Claude Code에서 바로 사용 가능합니다:

```
/youtube https://www.youtube.com/watch?v=VIDEO_ID
```

## 파일 구조

```
~/.claude/
├── commands/
│   └── youtube.md              # /youtube 슬래시 커맨드
├── scripts/
│   └── youtube_transcript.py   # 자막 추출 Python 스크립트
├── skills/
│   ├── youtube-insight/        # AI 인사이트 분석 프레임워크
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── insight-templates.md
│   └── obsidian-writer/        # Obsidian 노트 작성 규칙
│       ├── SKILL.md
│       └── references/
│           ├── vault-structure.md
│           └── note-examples.md
└── settings/
    └── youtube-vault-path.txt  # ⭐ Obsidian 볼트 경로 (데스크탑별 설정)
```

## 카테고리

| 카테고리 | 폴더 | 키워드 예시 |
|----------|------|-------------|
| 자기계발 | 01_자기계발 | 습관, 마인드셋, 생산성, 루틴 |
| 투자 | 02_투자 | 주식, 부동산, ETF, 경제 |
| 커리어 | 03_커리어 | 이직, 면접, 연봉, 직장 |
| 기술 | 04_기술 | 프로그래밍, AI, 개발, 자동화 |
| 비즈니스 | 05_비즈니스 | 창업, 마케팅, 브랜딩, 매출 |
| 기타 | 99_기타 | 위에 해당하지 않는 경우 |

## 의존성

- `youtube-transcript-api` (setup 시 자동 설치)
