export function pluralizeContainerType(
  type: string | null | undefined,
  options?: { uppercase?: boolean; fallback?: string },
): string {
  const fallback = options?.fallback ?? 'Unit'
  const raw = (type ?? '').trim() || fallback
  const lower = raw.toLowerCase()

  let plural = raw
  if (/(s|x|z|ch|sh)$/i.test(lower)) {
    plural = `${raw}es`
  } else if (/[bcdfghjklmnpqrstvwxyz]y$/i.test(lower)) {
    plural = `${raw.slice(0, -1)}ies`
  } else {
    plural = `${raw}s`
  }

  return options?.uppercase ? plural.toUpperCase() : plural
}
