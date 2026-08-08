/* tslint:disable */
/* eslint-disable */

export class NativeRangePlanner {
    free(): void;
    [Symbol.dispose](): void;
    clear(): void;
    delete(id: string): boolean;
    find_leaders(cursors: Array<any>, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    find_leaders_batch(cursor_batches: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    find_leaders_for_gid(gid: string, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    get_full_replica_leaders(replicas: number, role_age_ms: number, now: string, include_strict: boolean, peer_filter: any): any;
    get_gid_coordinates(gid: string, count: number): Array<any>;
    get_grid(from: string, count: number): Array<any>;
    get_samples(cursors: Array<any>, role_age_ms: number, now: string, only_intersecting: boolean, unique_replicators: any, peer_filter: any): Array<any>;
    include_matured_peers(peer_filter: any, replicas: number, role_age_ms: number, now: string, self_hash: string, include_self: boolean): any;
    len(): number;
    constructor(resolution: string);
    plan_leaders_for_gid(gid: string, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_leaders_for_gids_batch(gids: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_local_leaders_for_gids_batch(hashes: Array<any>, gids: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_repair_dispatch(entry_hashes: Array<any>, entry_gids: Array<any>, entry_requested_replicas: Array<any>, current_leader_batches: Array<any>, known_gid_peer_batches: Array<any>, known_entry_peer_batches: Array<any>, pending_modes: Array<any>, pending_peers_by_mode: Array<any>, optimistic_peers_by_mode: Array<any>, full_replica_repair_candidates: Array<any>, full_replica_repair_candidate_count: number, self_hash: string): Array<any>;
    plan_repair_dispatch_for_entries(entry_hashes: Array<any>, entry_gids: Array<any>, entry_requested_replicas: Array<any>, entry_coordinate_batches: Array<any>, known_gid_peer_batches: Array<any>, known_entry_peer_batches: Array<any>, pending_modes: Array<any>, pending_peers_by_mode: Array<any>, optimistic_peers_by_mode: Array<any>, full_replica_repair_candidates: Array<any>, full_replica_repair_candidate_count: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    put(id: string, hash: string, timestamp: string, start1: string, end1: string, start2: string, end2: string, width: string, mode: number): void;
}

export class NativeSharedLogState {
    free(): void;
    [Symbol.dispose](): void;
    add_gid_peers(gid: string, peers: Array<any>, reset: boolean): number;
    clear(): void;
    clear_entry_coordinates(): void;
    clear_entry_known_peers(): void;
    clear_gid_peers(): void;
    commit_entry_coordinates(hash: string, gid: string, hash_number: string, coordinates: Array<any>, next_hashes: Array<any>, assigned_to_range_boundary: boolean, requested_replicas: number): void;
    commit_entry_coordinates_batch(hashes: Array<any>, gids: Array<any>, hash_numbers: Array<any>, coordinate_batches: Array<any>, next_hash_batches: Array<any>, assigned_to_range_boundaries: Uint8Array, requested_replicas: Array<any>): void;
    commit_local_append_for_gid_compact(entry_hash: string, gid: string, entry_hash_number: string, next_hashes: Array<any>, delete_hashes: Array<any>, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    count_entry_coordinates_in_ranges(start1: Array<any>, end1: Array<any>, start2: Array<any>, end2: Array<any>, include_assigned_to_range_boundary: boolean): number;
    delete(id: string): boolean;
    delete_entry_coordinates(hash: string): boolean;
    delete_entry_coordinates_batch(hashes: Array<any>): void;
    delete_gid_peers(gid: string): boolean;
    entry_coordinate_hashes(): Array<any>;
    entry_hash_numbers_in_range(start1: string, end1: string, start2: string, end2: string): Array<any>;
    entry_hash_numbers_in_range_u64(start1: string, end1: string, start2: string, end2: string): BigUint64Array;
    entry_hashes_for_hash_numbers(hash_numbers: Array<any>): Array<any>;
    entry_hashes_for_hash_numbers_flat_u64(hash_numbers: BigUint64Array): Array<any>;
    entry_hashes_for_hash_numbers_u64(hash_numbers: BigUint64Array): Array<any>;
    find_leaders(cursors: Array<any>, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    find_leaders_batch(cursor_batches: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    get_entry_coordinates(hash: string): any;
    get_gid_coordinates(gid: string, count: number): Array<any>;
    get_grid(from: string, count: number): Array<any>;
    len(): number;
    mark_entries_known_by_peer(hashes: Array<any>, peer: string): void;
    constructor(resolution: string);
    plan_append_delivery(leaders: Array<any>, fallback_recipients: Array<any>, min_replicas: number, self_hash: string, is_leader: boolean, delivery_enabled: boolean, reliability_ack: boolean, min_acks: any, require_recipients: boolean): Array<any>;
    plan_append_for_gid(entry_hash: string, gid: string, entry_hash_number: string, next_hashes: Array<any>, replicas: number, full_replica_candidates: Array<any>, fallback_recipients: Array<any>, delivery_self_hash: string, delivery_enabled: boolean, reliability_ack: boolean, min_acks: any, require_recipients: boolean, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_append_for_gids_batch(entry_hashes: Array<any>, gids: Array<any>, entry_hash_numbers: Array<any>, next_hash_batches: Array<any>, replica_counts: Array<any>, full_replica_candidates: Array<any>, fallback_recipients: Array<any>, delivery_self_hash: string, delivery_enabled: boolean, reliability_ack: boolean, min_acks: any, require_recipients: boolean, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_append_leaders_for_delivery(leaders: Array<any>, full_replica_candidates: Array<any>, min_replicas: number): Array<any>;
    plan_entry_assignment_for_gid(gid: string, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_entry_leaders_for_gid(gid: string, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_leader_samples_for_gids_batch(gids: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_leaders_for_gids_batch(gids: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_local_append_for_gid(entry_hash: string, gid: string, entry_hash_number: string, next_hashes: Array<any>, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_local_append_for_gid_compact(entry_hash: string, gid: string, entry_hash_number: string, next_hashes: Array<any>, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_receive_coordinates_for_gids_batch(entry_hashes: Array<any>, gids: Array<any>, entry_hash_numbers: Array<any>, next_hash_batches: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_repair_dispatch_for_entries(entry_hashes: Array<any>, entry_gids: Array<any>, entry_requested_replicas: Array<any>, entry_coordinate_batches: Array<any>, pending_modes: Array<any>, pending_peers_by_mode: Array<any>, optimistic_peers_by_mode: Array<any>, full_replica_repair_candidates: Array<any>, full_replica_repair_candidate_count: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_repair_dispatch_for_resident_entries(pending_modes: Array<any>, pending_peers_by_mode: Array<any>, optimistic_gids_by_mode: Array<any>, optimistic_peers_by_gid_by_mode: Array<any>, full_replica_repair_candidates: Array<any>, full_replica_repair_candidate_count: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    put(id: string, hash: string, timestamp: string, start1: string, end1: string, start2: string, end2: string, width: string, mode: number): void;
    put_entry_coordinates(hash: string, gid: string, hash_number: string, coordinates: Array<any>, assigned_to_range_boundary: boolean, requested_replicas: number): void;
    remove_entries_known_by_peer(hashes: Array<any>, peer: string): void;
    remove_gid_peer(peer: string, gid: any): void;
    remove_gid_peers(peer: string, gids: Array<any>): void;
    remove_peer_from_entry_known_peers(peer: string): void;
}

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
    readonly memory: WebAssembly.Memory;
    readonly __wbg_nativerangeplanner_free: (a: number, b: number) => void;
    readonly __wbg_nativesharedlogstate_free: (a: number, b: number) => void;
    readonly nativerangeplanner_clear: (a: number) => void;
    readonly nativerangeplanner_delete: (a: number, b: number, c: number) => number;
    readonly nativerangeplanner_find_leaders: (a: number, b: any, c: number, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativerangeplanner_find_leaders_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativerangeplanner_find_leaders_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativerangeplanner_get_full_replica_leaders: (a: number, b: number, c: number, d: number, e: number, f: number, g: any) => [number, number, number];
    readonly nativerangeplanner_get_gid_coordinates: (a: number, b: number, c: number, d: number) => any;
    readonly nativerangeplanner_get_grid: (a: number, b: number, c: number, d: number) => [number, number, number];
    readonly nativerangeplanner_get_samples: (a: number, b: any, c: number, d: number, e: number, f: number, g: any, h: any) => [number, number, number];
    readonly nativerangeplanner_include_matured_peers: (a: number, b: any, c: number, d: number, e: number, f: number, g: number, h: number, i: number) => [number, number, number];
    readonly nativerangeplanner_len: (a: number) => number;
    readonly nativerangeplanner_new: (a: number, b: number) => number;
    readonly nativerangeplanner_plan_leaders_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativerangeplanner_plan_leaders_for_gids_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativerangeplanner_plan_local_leaders_for_gids_batch: (a: number, b: any, c: any, d: any, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativerangeplanner_plan_repair_dispatch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any, l: number, m: number, n: number) => [number, number, number];
    readonly nativerangeplanner_plan_repair_dispatch_for_entries: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any, l: number, m: number, n: number, o: number, p: any, q: number, r: number, s: number, t: number, u: number, v: number) => [number, number, number];
    readonly nativerangeplanner_put: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number) => [number, number];
    readonly nativesharedlogstate_add_gid_peers: (a: number, b: number, c: number, d: any, e: number) => [number, number, number];
    readonly nativesharedlogstate_clear: (a: number) => void;
    readonly nativesharedlogstate_clear_entry_coordinates: (a: number) => void;
    readonly nativesharedlogstate_clear_entry_known_peers: (a: number) => void;
    readonly nativesharedlogstate_clear_gid_peers: (a: number) => void;
    readonly nativesharedlogstate_commit_entry_coordinates: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: any, j: number, k: number) => [number, number];
    readonly nativesharedlogstate_commit_entry_coordinates_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any) => [number, number];
    readonly nativesharedlogstate_commit_local_append_for_gid_compact: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: any, o: number, p: number, q: number, r: number, s: number, t: number) => [number, number, number];
    readonly nativesharedlogstate_count_entry_coordinates_in_ranges: (a: number, b: any, c: any, d: any, e: any, f: number) => [number, number, number];
    readonly nativesharedlogstate_delete: (a: number, b: number, c: number) => number;
    readonly nativesharedlogstate_delete_entry_coordinates: (a: number, b: number, c: number) => number;
    readonly nativesharedlogstate_delete_entry_coordinates_batch: (a: number, b: any) => [number, number];
    readonly nativesharedlogstate_delete_gid_peers: (a: number, b: number, c: number) => number;
    readonly nativesharedlogstate_entry_coordinate_hashes: (a: number) => any;
    readonly nativesharedlogstate_entry_hash_numbers_in_range: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number) => [number, number, number];
    readonly nativesharedlogstate_entry_hash_numbers_in_range_u64: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number) => [number, number, number];
    readonly nativesharedlogstate_entry_hashes_for_hash_numbers: (a: number, b: any) => [number, number, number];
    readonly nativesharedlogstate_entry_hashes_for_hash_numbers_flat_u64: (a: number, b: any) => any;
    readonly nativesharedlogstate_entry_hashes_for_hash_numbers_u64: (a: number, b: any) => [number, number, number];
    readonly nativesharedlogstate_find_leaders: (a: number, b: any, c: number, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativesharedlogstate_find_leaders_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativesharedlogstate_get_entry_coordinates: (a: number, b: number, c: number) => any;
    readonly nativesharedlogstate_get_gid_coordinates: (a: number, b: number, c: number, d: number) => any;
    readonly nativesharedlogstate_get_grid: (a: number, b: number, c: number, d: number) => [number, number, number];
    readonly nativesharedlogstate_len: (a: number) => number;
    readonly nativesharedlogstate_mark_entries_known_by_peer: (a: number, b: any, c: number, d: number) => [number, number];
    readonly nativesharedlogstate_new: (a: number, b: number) => number;
    readonly nativesharedlogstate_plan_append_delivery: (a: number, b: any, c: any, d: number, e: number, f: number, g: number, h: number, i: number, j: any, k: number) => [number, number, number];
    readonly nativesharedlogstate_plan_append_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: any, k: any, l: number, m: number, n: number, o: number, p: any, q: number, r: number, s: number, t: number, u: any, v: number, w: number, x: number, y: number, z: number, a1: number) => [number, number, number];
    readonly nativesharedlogstate_plan_append_for_gids_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: number, j: number, k: number, l: number, m: any, n: number, o: number, p: number, q: number, r: any, s: number, t: number, u: number, v: number, w: number, x: number) => [number, number, number];
    readonly nativesharedlogstate_plan_append_leaders_for_delivery: (a: number, b: any, c: any, d: number) => [number, number, number];
    readonly nativesharedlogstate_plan_entry_assignment_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativesharedlogstate_plan_entry_leaders_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativesharedlogstate_plan_leader_samples_for_gids_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativesharedlogstate_plan_leaders_for_gids_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativesharedlogstate_plan_local_append_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: any, n: number, o: number, p: number, q: number, r: number, s: number) => [number, number, number];
    readonly nativesharedlogstate_plan_local_append_for_gid_compact: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: any, n: number, o: number, p: number, q: number, r: number, s: number) => [number, number, number];
    readonly nativesharedlogstate_plan_receive_coordinates_for_gids_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: number, h: number, i: number, j: any, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativesharedlogstate_plan_repair_dispatch_for_entries: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: number, k: number, l: number, m: number, n: any, o: number, p: number, q: number, r: number, s: number, t: number) => [number, number, number];
    readonly nativesharedlogstate_plan_repair_dispatch_for_resident_entries: (a: number, b: any, c: any, d: any, e: any, f: any, g: number, h: number, i: number, j: number, k: any, l: number, m: number, n: number, o: number, p: number, q: number) => [number, number, number];
    readonly nativesharedlogstate_put: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number) => [number, number];
    readonly nativesharedlogstate_put_entry_coordinates: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number) => [number, number];
    readonly nativesharedlogstate_remove_entries_known_by_peer: (a: number, b: any, c: number, d: number) => [number, number];
    readonly nativesharedlogstate_remove_gid_peer: (a: number, b: number, c: number, d: any) => [number, number];
    readonly nativesharedlogstate_remove_gid_peers: (a: number, b: number, c: number, d: any) => [number, number];
    readonly nativesharedlogstate_remove_peer_from_entry_known_peers: (a: number, b: number, c: number) => void;
    readonly __wbindgen_malloc: (a: number, b: number) => number;
    readonly __wbindgen_realloc: (a: number, b: number, c: number, d: number) => number;
    readonly __wbindgen_externrefs: WebAssembly.Table;
    readonly __externref_table_dealloc: (a: number) => void;
    readonly __wbindgen_start: () => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;

/**
 * Instantiates the given `module`, which can either be bytes or
 * a precompiled `WebAssembly.Module`.
 *
 * @param {{ module: SyncInitInput }} module - Passing `SyncInitInput` directly is deprecated.
 *
 * @returns {InitOutput}
 */
export function initSync(module: { module: SyncInitInput } | SyncInitInput): InitOutput;

/**
 * If `module_or_path` is {RequestInfo} or {URL}, makes a request and
 * for everything else, calls `WebAssembly.instantiate` directly.
 *
 * @param {{ module_or_path: InitInput | Promise<InitInput> }} module_or_path - Passing `InitInput` directly is deprecated.
 *
 * @returns {Promise<InitOutput>}
 */
export default function __wbg_init (module_or_path?: { module_or_path: InitInput | Promise<InitInput> } | InitInput | Promise<InitInput>): Promise<InitOutput>;
