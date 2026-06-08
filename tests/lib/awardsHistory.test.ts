import { describe, it, expect } from 'vitest';
import { CANONICAL_IDS, ID_ALIASES } from '../../src/lib/awardsHistory';

describe('CANONICAL_IDS', () => {
  it('includes open, ladies, vets for both series', () => {
    for (const series of ['road-gp', 'fell'] as const) {
      expect(CANONICAL_IDS[series]).toContain('open');
      expect(CANONICAL_IDS[series]).toContain('ladies');
      expect(CANONICAL_IDS[series]).toContain('vets');
    }
  });

  it('road-gp includes lady-vets; fell does not', () => {
    expect(CANONICAL_IDS['road-gp']).toContain('lady-vets');
    expect(CANONICAL_IDS['fell']).not.toContain('lady-vets');
  });
});

describe('ID_ALIASES', () => {
  it('maps women to ladies', () => {
    expect(ID_ALIASES['women']).toBe('ladies');
  });

  it('maps v50 to vet50s', () => {
    expect(ID_ALIASES['v50']).toBe('vet50s');
  });
});
