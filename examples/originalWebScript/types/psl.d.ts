declare module 'psl' {
  export function get(domain: string): string | null;
  export function parse(domain: string): { domain?: string };
}