const { readFileSync, readdirSync, statSync } = require('node:fs')
const { join, resolve } = require('node:path')

const ROOT = resolve(__dirname, '..')
const roots = ['app', 'components', 'src']
const allowedExtensions = new Set(['.ts', '.tsx', '.js', '.jsx'])

function collectFiles(dir, acc) {
  const entries = readdirSync(dir, { withFileTypes: true })
  for (const entry of entries) {
    const fullPath = join(dir, entry.name)
    if (entry.isDirectory()) {
      collectFiles(fullPath, acc)
      continue
    }
    const ext = fullPath.slice(fullPath.lastIndexOf('.'))
    if (allowedExtensions.has(ext)) acc.push(fullPath)
  }
}

const files = []
for (const rel of roots) {
  const abs = join(ROOT, rel)
  try {
    if (statSync(abs).isDirectory()) collectFiles(abs, files)
  } catch (_) {
    // Optional directory may not exist in all setups.
  }
}

// Guard against print/physical units in text arbitrary values, e.g. text-[11in], text-[12pt]
const invalidTextUnitRegex = /\btext-\[[^\]]*(?:cm|mm|in|pt|pc)\]/g
const offenders = []

for (const file of files) {
  const content = readFileSync(file, 'utf8')
  const matches = content.match(invalidTextUnitRegex)
  if (matches && matches.length > 0) {
    offenders.push({
      file: file.replace(`${ROOT}\\`, '').replace(`${ROOT}/`, ''),
      matches: Array.from(new Set(matches)),
    })
  }
}

if (offenders.length > 0) {
  console.error('Invalid Tailwind text unit(s) detected. Use px/rem token scales instead of inches.')
  for (const offender of offenders) {
    console.error(`- ${offender.file}: ${offender.matches.join(', ')}`)
  }
  process.exit(1)
}

console.log('Tailwind text unit guard passed.')
