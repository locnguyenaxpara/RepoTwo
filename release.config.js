module.exports = {
    branches: ['main', 'release/*'],
    tagFormat: '${version}',
    plugins: [
        '@semantic-release/commit-analyzer',
        ['@semantic-release/release-notes-generator',
        {
            preset: 'conventionalcommits',
            presetConfig: {
                types: [
                    { type: "feat", section: "Features" },
                    { type: "fix", section: "Bug Fixes" },
                    { type: "hotfix", section: "Bug Fixes" },
                    { type: "docs", section: "Docs" },
                    { type: "refactor", section: "Refactoring" },
                    { type: "perf", section: "Performance Improvements" },
                    { type: "ci", section: "CI/CD Changes" },
                    { type: "test", section: "Tests" },
                ],
            },
            writerOpts: {
                commitsSort: ["subject", "scope"],
            },
        }],
        [
            '@semantic-release/changelog',
            {
                changelogFile: 'CHANGELOG.md',
            },
        ],
        [
            '@semantic-release/git',
            {
                assets: ['CHANGELOG.md', 'package.json'],
                message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
            },
        ]
    ],
};