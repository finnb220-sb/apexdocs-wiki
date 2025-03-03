import { GitHub } from '@actions/github/lib/utils';
import { Context } from '@actions/github/lib/context';

/**
 * Interface used by the run function / interface.
 * This is a partial as the yml passes these:
 *  - require,
 * - __original_require__,
 * - github,
 * - context,
 * - core,
 * - exec,
 * - glob,
 * - io,
 * - fetch
 *
 * Sadly, I've not figured out how to enumerate these in Ts yet.
 */
export interface globals {
    github:InstanceType<typeof GitHub>,
    context : Context,
}