/* @ts-self-types="./shared_log_rust.d.ts" */

export class NativeRangePlanner {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativeRangePlannerFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativerangeplanner_free(ptr, 0);
    }
    clear() {
        wasm.nativerangeplanner_clear(this.__wbg_ptr);
    }
    /**
     * @param {string} id
     * @returns {boolean}
     */
    delete(id) {
        const ptr0 = passStringToWasm0(id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_delete(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} cursors
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    find_leaders(cursors, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_find_leaders(this.__wbg_ptr, cursors, replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} cursor_batches
     * @param {Array<any>} replica_counts
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    find_leaders_batch(cursor_batches, replica_counts, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_find_leaders_batch(this.__wbg_ptr, cursor_batches, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} gid
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    find_leaders_for_gid(gid, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_find_leaders_for_gid(this.__wbg_ptr, ptr0, len0, replicas, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {boolean} include_strict
     * @param {any} peer_filter
     * @returns {any}
     */
    get_full_replica_leaders(replicas, role_age_ms, now, include_strict, peer_filter) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_get_full_replica_leaders(this.__wbg_ptr, replicas, role_age_ms, ptr0, len0, include_strict, peer_filter);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} gid
     * @param {number} count
     * @returns {Array<any>}
     */
    get_gid_coordinates(gid, count) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_get_gid_coordinates(this.__wbg_ptr, ptr0, len0, count);
        return ret;
    }
    /**
     * @param {string} from
     * @param {number} count
     * @returns {Array<any>}
     */
    get_grid(from, count) {
        const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_get_grid(this.__wbg_ptr, ptr0, len0, count);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} cursors
     * @param {number} role_age_ms
     * @param {string} now
     * @param {boolean} only_intersecting
     * @param {any} unique_replicators
     * @param {any} peer_filter
     * @returns {Array<any>}
     */
    get_samples(cursors, role_age_ms, now, only_intersecting, unique_replicators, peer_filter) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_get_samples(this.__wbg_ptr, cursors, role_age_ms, ptr0, len0, only_intersecting, unique_replicators, peer_filter);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {any} peer_filter
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} include_self
     * @returns {any}
     */
    include_matured_peers(peer_filter, replicas, role_age_ms, now, self_hash, include_self) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_include_matured_peers(this.__wbg_ptr, peer_filter, replicas, role_age_ms, ptr0, len0, ptr1, len1, include_self);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {number}
     */
    len() {
        const ret = wasm.nativerangeplanner_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {string} resolution
     */
    constructor(resolution) {
        const ptr0 = passStringToWasm0(resolution, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_new(ptr0, len0);
        this.__wbg_ptr = ret;
        NativeRangePlannerFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {string} gid
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_leaders_for_gid(gid, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_plan_leaders_for_gid(this.__wbg_ptr, ptr0, len0, replicas, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} gids
     * @param {Array<any>} replica_counts
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_leaders_for_gids_batch(gids, replica_counts, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_plan_leaders_for_gids_batch(this.__wbg_ptr, gids, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} gids
     * @param {Array<any>} replica_counts
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_local_leaders_for_gids_batch(hashes, gids, replica_counts, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_plan_local_leaders_for_gids_batch(this.__wbg_ptr, hashes, gids, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} entry_hashes
     * @param {Array<any>} entry_gids
     * @param {Array<any>} entry_requested_replicas
     * @param {Array<any>} current_leader_batches
     * @param {Array<any>} known_gid_peer_batches
     * @param {Array<any>} known_entry_peer_batches
     * @param {Array<any>} pending_modes
     * @param {Array<any>} pending_peers_by_mode
     * @param {Array<any>} optimistic_peers_by_mode
     * @param {Array<any>} full_replica_repair_candidates
     * @param {number} full_replica_repair_candidate_count
     * @param {string} self_hash
     * @returns {Array<any>}
     */
    plan_repair_dispatch(entry_hashes, entry_gids, entry_requested_replicas, current_leader_batches, known_gid_peer_batches, known_entry_peer_batches, pending_modes, pending_peers_by_mode, optimistic_peers_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, self_hash) {
        const ptr0 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_plan_repair_dispatch(this.__wbg_ptr, entry_hashes, entry_gids, entry_requested_replicas, current_leader_batches, known_gid_peer_batches, known_entry_peer_batches, pending_modes, pending_peers_by_mode, optimistic_peers_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} entry_hashes
     * @param {Array<any>} entry_gids
     * @param {Array<any>} entry_requested_replicas
     * @param {Array<any>} entry_coordinate_batches
     * @param {Array<any>} known_gid_peer_batches
     * @param {Array<any>} known_entry_peer_batches
     * @param {Array<any>} pending_modes
     * @param {Array<any>} pending_peers_by_mode
     * @param {Array<any>} optimistic_peers_by_mode
     * @param {Array<any>} full_replica_repair_candidates
     * @param {number} full_replica_repair_candidate_count
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_repair_dispatch_for_entries(entry_hashes, entry_gids, entry_requested_replicas, entry_coordinate_batches, known_gid_peer_batches, known_entry_peer_batches, pending_modes, pending_peers_by_mode, optimistic_peers_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_plan_repair_dispatch_for_entries(this.__wbg_ptr, entry_hashes, entry_gids, entry_requested_replicas, entry_coordinate_batches, known_gid_peer_batches, known_entry_peer_batches, pending_modes, pending_peers_by_mode, optimistic_peers_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} id
     * @param {string} hash
     * @param {string} timestamp
     * @param {string} start1
     * @param {string} end1
     * @param {string} start2
     * @param {string} end2
     * @param {string} width
     * @param {number} mode
     */
    put(id, hash, timestamp, start1, end1, start2, end2, width, mode) {
        const ptr0 = passStringToWasm0(id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(timestamp, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(start1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(end1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(start2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ptr6 = passStringToWasm0(end2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len6 = WASM_VECTOR_LEN;
        const ptr7 = passStringToWasm0(width, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len7 = WASM_VECTOR_LEN;
        const ret = wasm.nativerangeplanner_put(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, ptr6, len6, ptr7, len7, mode);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
}
if (Symbol.dispose) NativeRangePlanner.prototype[Symbol.dispose] = NativeRangePlanner.prototype.free;

export class NativeSharedLogState {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativeSharedLogStateFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativesharedlogstate_free(ptr, 0);
    }
    /**
     * @param {string} gid
     * @param {Array<any>} peers
     * @param {boolean} reset
     * @returns {number}
     */
    add_gid_peers(gid, peers, reset) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_add_gid_peers(this.__wbg_ptr, ptr0, len0, peers, reset);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    clear() {
        wasm.nativesharedlogstate_clear(this.__wbg_ptr);
    }
    clear_entry_coordinates() {
        wasm.nativesharedlogstate_clear_entry_coordinates(this.__wbg_ptr);
    }
    clear_entry_known_peers() {
        wasm.nativesharedlogstate_clear_entry_known_peers(this.__wbg_ptr);
    }
    clear_gid_peers() {
        wasm.nativesharedlogstate_clear_gid_peers(this.__wbg_ptr);
    }
    /**
     * @param {string} hash
     * @param {string} gid
     * @param {string} hash_number
     * @param {Array<any>} coordinates
     * @param {Array<any>} next_hashes
     * @param {boolean} assigned_to_range_boundary
     * @param {number} requested_replicas
     */
    commit_entry_coordinates(hash, gid, hash_number, coordinates, next_hashes, assigned_to_range_boundary, requested_replicas) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(hash_number, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_commit_entry_coordinates(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, coordinates, next_hashes, assigned_to_range_boundary, requested_replicas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} gids
     * @param {Array<any>} hash_numbers
     * @param {Array<any>} coordinate_batches
     * @param {Array<any>} next_hash_batches
     * @param {Uint8Array} assigned_to_range_boundaries
     * @param {Array<any>} requested_replicas
     */
    commit_entry_coordinates_batch(hashes, gids, hash_numbers, coordinate_batches, next_hash_batches, assigned_to_range_boundaries, requested_replicas) {
        const ret = wasm.nativesharedlogstate_commit_entry_coordinates_batch(this.__wbg_ptr, hashes, gids, hash_numbers, coordinate_batches, next_hash_batches, assigned_to_range_boundaries, requested_replicas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} entry_hash
     * @param {string} gid
     * @param {string} entry_hash_number
     * @param {Array<any>} next_hashes
     * @param {Array<any>} delete_hashes
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    commit_local_append_for_gid_compact(entry_hash, gid, entry_hash_number, next_hashes, delete_hashes, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(entry_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(entry_hash_number, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_commit_local_append_for_gid_compact(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, next_hashes, delete_hashes, replicas, role_age_ms, ptr3, len3, peer_filter, expand_peer_filter, ptr4, len4, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} start1
     * @param {Array<any>} end1
     * @param {Array<any>} start2
     * @param {Array<any>} end2
     * @param {boolean} include_assigned_to_range_boundary
     * @returns {number}
     */
    count_entry_coordinates_in_ranges(start1, end1, start2, end2, include_assigned_to_range_boundary) {
        const ret = wasm.nativesharedlogstate_count_entry_coordinates_in_ranges(this.__wbg_ptr, start1, end1, start2, end2, include_assigned_to_range_boundary);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {string} id
     * @returns {boolean}
     */
    delete(id) {
        const ptr0 = passStringToWasm0(id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_delete(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    delete_entry_coordinates(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_delete_entry_coordinates(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} hashes
     */
    delete_entry_coordinates_batch(hashes) {
        const ret = wasm.nativesharedlogstate_delete_entry_coordinates_batch(this.__wbg_ptr, hashes);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} gid
     * @returns {boolean}
     */
    delete_gid_peers(gid) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_delete_gid_peers(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @returns {Array<any>}
     */
    entry_coordinate_hashes() {
        const ret = wasm.nativesharedlogstate_entry_coordinate_hashes(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {string} start1
     * @param {string} end1
     * @param {string} start2
     * @param {string} end2
     * @returns {Array<any>}
     */
    entry_hash_numbers_in_range(start1, end1, start2, end2) {
        const ptr0 = passStringToWasm0(start1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(end1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(start2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(end2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_entry_hash_numbers_in_range(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} start1
     * @param {string} end1
     * @param {string} start2
     * @param {string} end2
     * @returns {BigUint64Array}
     */
    entry_hash_numbers_in_range_u64(start1, end1, start2, end2) {
        const ptr0 = passStringToWasm0(start1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(end1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(start2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(end2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_entry_hash_numbers_in_range_u64(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hash_numbers
     * @returns {Array<any>}
     */
    entry_hashes_for_hash_numbers(hash_numbers) {
        const ret = wasm.nativesharedlogstate_entry_hashes_for_hash_numbers(this.__wbg_ptr, hash_numbers);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} hash_numbers
     * @returns {Array<any>}
     */
    entry_hashes_for_hash_numbers_flat_u64(hash_numbers) {
        const ret = wasm.nativesharedlogstate_entry_hashes_for_hash_numbers_flat_u64(this.__wbg_ptr, hash_numbers);
        return ret;
    }
    /**
     * @param {BigUint64Array} hash_numbers
     * @returns {Array<any>}
     */
    entry_hashes_for_hash_numbers_u64(hash_numbers) {
        const ret = wasm.nativesharedlogstate_entry_hashes_for_hash_numbers_u64(this.__wbg_ptr, hash_numbers);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} cursors
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    find_leaders(cursors, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_find_leaders(this.__wbg_ptr, cursors, replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} cursor_batches
     * @param {Array<any>} replica_counts
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    find_leaders_batch(cursor_batches, replica_counts, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_find_leaders_batch(this.__wbg_ptr, cursor_batches, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @returns {any}
     */
    get_entry_coordinates(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_get_entry_coordinates(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string} gid
     * @param {number} count
     * @returns {Array<any>}
     */
    get_gid_coordinates(gid, count) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_get_gid_coordinates(this.__wbg_ptr, ptr0, len0, count);
        return ret;
    }
    /**
     * @param {string} from
     * @param {number} count
     * @returns {Array<any>}
     */
    get_grid(from, count) {
        const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_get_grid(this.__wbg_ptr, ptr0, len0, count);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {number}
     */
    len() {
        const ret = wasm.nativesharedlogstate_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} peer
     */
    mark_entries_known_by_peer(hashes, peer) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_mark_entries_known_by_peer(this.__wbg_ptr, hashes, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} resolution
     */
    constructor(resolution) {
        const ptr0 = passStringToWasm0(resolution, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_new(ptr0, len0);
        this.__wbg_ptr = ret;
        NativeSharedLogStateFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {Array<any>} leaders
     * @param {Array<any>} fallback_recipients
     * @param {number} min_replicas
     * @param {string} self_hash
     * @param {boolean} is_leader
     * @param {boolean} delivery_enabled
     * @param {boolean} reliability_ack
     * @param {any} min_acks
     * @param {boolean} require_recipients
     * @returns {Array<any>}
     */
    plan_append_delivery(leaders, fallback_recipients, min_replicas, self_hash, is_leader, delivery_enabled, reliability_ack, min_acks, require_recipients) {
        const ptr0 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_append_delivery(this.__wbg_ptr, leaders, fallback_recipients, min_replicas, ptr0, len0, is_leader, delivery_enabled, reliability_ack, min_acks, require_recipients);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} entry_hash
     * @param {string} gid
     * @param {string} entry_hash_number
     * @param {Array<any>} next_hashes
     * @param {number} replicas
     * @param {Array<any>} full_replica_candidates
     * @param {Array<any>} fallback_recipients
     * @param {string} delivery_self_hash
     * @param {boolean} delivery_enabled
     * @param {boolean} reliability_ack
     * @param {any} min_acks
     * @param {boolean} require_recipients
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_append_for_gid(entry_hash, gid, entry_hash_number, next_hashes, replicas, full_replica_candidates, fallback_recipients, delivery_self_hash, delivery_enabled, reliability_ack, min_acks, require_recipients, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(entry_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(entry_hash_number, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(delivery_self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_append_for_gid(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, next_hashes, replicas, full_replica_candidates, fallback_recipients, ptr3, len3, delivery_enabled, reliability_ack, min_acks, require_recipients, role_age_ms, ptr4, len4, peer_filter, expand_peer_filter, ptr5, len5, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} entry_hashes
     * @param {Array<any>} gids
     * @param {Array<any>} entry_hash_numbers
     * @param {Array<any>} next_hash_batches
     * @param {Array<any>} replica_counts
     * @param {Array<any>} full_replica_candidates
     * @param {Array<any>} fallback_recipients
     * @param {string} delivery_self_hash
     * @param {boolean} delivery_enabled
     * @param {boolean} reliability_ack
     * @param {any} min_acks
     * @param {boolean} require_recipients
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_append_for_gids_batch(entry_hashes, gids, entry_hash_numbers, next_hash_batches, replica_counts, full_replica_candidates, fallback_recipients, delivery_self_hash, delivery_enabled, reliability_ack, min_acks, require_recipients, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(delivery_self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_append_for_gids_batch(this.__wbg_ptr, entry_hashes, gids, entry_hash_numbers, next_hash_batches, replica_counts, full_replica_candidates, fallback_recipients, ptr0, len0, delivery_enabled, reliability_ack, min_acks, require_recipients, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} leaders
     * @param {Array<any>} full_replica_candidates
     * @param {number} min_replicas
     * @returns {Array<any>}
     */
    plan_append_leaders_for_delivery(leaders, full_replica_candidates, min_replicas) {
        const ret = wasm.nativesharedlogstate_plan_append_leaders_for_delivery(this.__wbg_ptr, leaders, full_replica_candidates, min_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} gid
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_entry_assignment_for_gid(gid, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_entry_assignment_for_gid(this.__wbg_ptr, ptr0, len0, replicas, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} gid
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_entry_leaders_for_gid(gid, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_entry_leaders_for_gid(this.__wbg_ptr, ptr0, len0, replicas, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} gids
     * @param {Array<any>} replica_counts
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_leader_samples_for_gids_batch(gids, replica_counts, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_leader_samples_for_gids_batch(this.__wbg_ptr, gids, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} gids
     * @param {Array<any>} replica_counts
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_leaders_for_gids_batch(gids, replica_counts, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_leaders_for_gids_batch(this.__wbg_ptr, gids, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} entry_hash
     * @param {string} gid
     * @param {string} entry_hash_number
     * @param {Array<any>} next_hashes
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_local_append_for_gid(entry_hash, gid, entry_hash_number, next_hashes, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(entry_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(entry_hash_number, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_local_append_for_gid(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, next_hashes, replicas, role_age_ms, ptr3, len3, peer_filter, expand_peer_filter, ptr4, len4, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} entry_hash
     * @param {string} gid
     * @param {string} entry_hash_number
     * @param {Array<any>} next_hashes
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_local_append_for_gid_compact(entry_hash, gid, entry_hash_number, next_hashes, replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(entry_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(entry_hash_number, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_local_append_for_gid_compact(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, next_hashes, replicas, role_age_ms, ptr3, len3, peer_filter, expand_peer_filter, ptr4, len4, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} entry_hashes
     * @param {Array<any>} gids
     * @param {Array<any>} entry_hash_numbers
     * @param {Array<any>} next_hash_batches
     * @param {Array<any>} replica_counts
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_receive_coordinates_for_gids_batch(entry_hashes, gids, entry_hash_numbers, next_hash_batches, replica_counts, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_receive_coordinates_for_gids_batch(this.__wbg_ptr, entry_hashes, gids, entry_hash_numbers, next_hash_batches, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} entry_hashes
     * @param {Array<any>} entry_gids
     * @param {Array<any>} entry_requested_replicas
     * @param {Array<any>} entry_coordinate_batches
     * @param {Array<any>} pending_modes
     * @param {Array<any>} pending_peers_by_mode
     * @param {Array<any>} optimistic_peers_by_mode
     * @param {Array<any>} full_replica_repair_candidates
     * @param {number} full_replica_repair_candidate_count
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_repair_dispatch_for_entries(entry_hashes, entry_gids, entry_requested_replicas, entry_coordinate_batches, pending_modes, pending_peers_by_mode, optimistic_peers_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_repair_dispatch_for_entries(this.__wbg_ptr, entry_hashes, entry_gids, entry_requested_replicas, entry_coordinate_batches, pending_modes, pending_peers_by_mode, optimistic_peers_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} pending_modes
     * @param {Array<any>} pending_peers_by_mode
     * @param {Array<any>} optimistic_gids_by_mode
     * @param {Array<any>} optimistic_peers_by_gid_by_mode
     * @param {Array<any>} full_replica_repair_candidates
     * @param {number} full_replica_repair_candidate_count
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {Array<any>}
     */
    plan_repair_dispatch_for_resident_entries(pending_modes, pending_peers_by_mode, optimistic_gids_by_mode, optimistic_peers_by_gid_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_plan_repair_dispatch_for_resident_entries(this.__wbg_ptr, pending_modes, pending_peers_by_mode, optimistic_gids_by_mode, optimistic_peers_by_gid_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} id
     * @param {string} hash
     * @param {string} timestamp
     * @param {string} start1
     * @param {string} end1
     * @param {string} start2
     * @param {string} end2
     * @param {string} width
     * @param {number} mode
     */
    put(id, hash, timestamp, start1, end1, start2, end2, width, mode) {
        const ptr0 = passStringToWasm0(id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(timestamp, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(start1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(end1, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(start2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ptr6 = passStringToWasm0(end2, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len6 = WASM_VECTOR_LEN;
        const ptr7 = passStringToWasm0(width, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len7 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_put(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, ptr6, len6, ptr7, len7, mode);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} hash
     * @param {string} gid
     * @param {string} hash_number
     * @param {Array<any>} coordinates
     * @param {boolean} assigned_to_range_boundary
     * @param {number} requested_replicas
     */
    put_entry_coordinates(hash, gid, hash_number, coordinates, assigned_to_range_boundary, requested_replicas) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(hash_number, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_put_entry_coordinates(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, coordinates, assigned_to_range_boundary, requested_replicas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} peer
     */
    remove_entries_known_by_peer(hashes, peer) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_remove_entries_known_by_peer(this.__wbg_ptr, hashes, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} peer
     * @param {any} gid
     */
    remove_gid_peer(peer, gid) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_remove_gid_peer(this.__wbg_ptr, ptr0, len0, gid);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} peer
     * @param {Array<any>} gids
     */
    remove_gid_peers(peer, gids) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativesharedlogstate_remove_gid_peers(this.__wbg_ptr, ptr0, len0, gids);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} peer
     */
    remove_peer_from_entry_known_peers(peer) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.nativesharedlogstate_remove_peer_from_entry_known_peers(this.__wbg_ptr, ptr0, len0);
    }
}
if (Symbol.dispose) NativeSharedLogState.prototype[Symbol.dispose] = NativeSharedLogState.prototype.free;
function __wbg_get_imports() {
    const import0 = {
        __proto__: null,
        __wbg___wbindgen_boolean_get_2304fb8c853028c8: function(arg0) {
            const v = arg0;
            const ret = typeof(v) === 'boolean' ? v : undefined;
            return isLikeNone(ret) ? 0xFFFFFF : ret ? 1 : 0;
        },
        __wbg___wbindgen_is_null_2042690d351e14f0: function(arg0) {
            const ret = arg0 === null;
            return ret;
        },
        __wbg___wbindgen_is_undefined_35bb9f4c7fd651d5: function(arg0) {
            const ret = arg0 === undefined;
            return ret;
        },
        __wbg___wbindgen_number_get_f73a1244370fcc2c: function(arg0, arg1) {
            const obj = arg1;
            const ret = typeof(obj) === 'number' ? obj : undefined;
            getDataViewMemory0().setFloat64(arg0 + 8 * 1, isLikeNone(ret) ? 0 : ret, true);
            getDataViewMemory0().setInt32(arg0 + 4 * 0, !isLikeNone(ret), true);
        },
        __wbg___wbindgen_string_get_d109740c0d18f4d7: function(arg0, arg1) {
            const obj = arg1;
            const ret = typeof(obj) === 'string' ? obj : undefined;
            var ptr1 = isLikeNone(ret) ? 0 : passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            var len1 = WASM_VECTOR_LEN;
            getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
            getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
        },
        __wbg___wbindgen_throw_9c31b086c2b26051: function(arg0, arg1) {
            throw new Error(getStringFromWasm0(arg0, arg1));
        },
        __wbg_from_fa561fa561dc8031: function(arg0) {
            const ret = Array.from(arg0);
            return ret;
        },
        __wbg_get_98fdf51d029a75eb: function(arg0, arg1) {
            const ret = arg0[arg1 >>> 0];
            return ret;
        },
        __wbg_get_index_c051becca25aa6d8: function(arg0, arg1) {
            const ret = arg0[arg1 >>> 0];
            return ret;
        },
        __wbg_get_unchecked_1dfe6d05ad91d9b7: function(arg0, arg1) {
            const ret = arg0[arg1 >>> 0];
            return ret;
        },
        __wbg_isArray_94898ed3aad6947b: function(arg0) {
            const ret = Array.isArray(arg0);
            return ret;
        },
        __wbg_length_2591a0f4f659a55c: function(arg0) {
            const ret = arg0.length;
            return ret;
        },
        __wbg_length_56fcd3e2b7e0299d: function(arg0) {
            const ret = arg0.length;
            return ret;
        },
        __wbg_length_a4365e969857a2c9: function(arg0) {
            const ret = arg0.length;
            return ret;
        },
        __wbg_new_310879b66b6e95e1: function() {
            const ret = new Array();
            return ret;
        },
        __wbg_new_from_slice_488f0668f819d09d: function(arg0, arg1) {
            const ret = new BigUint64Array(getArrayU64FromWasm0(arg0, arg1));
            return ret;
        },
        __wbg_prototypesetcall_e8ac1641c06469bb: function(arg0, arg1, arg2) {
            BigUint64Array.prototype.set.call(getArrayU64FromWasm0(arg0, arg1), arg2);
        },
        __wbg_push_b77c476b01548d0a: function(arg0, arg1) {
            const ret = arg0.push(arg1);
            return ret;
        },
        __wbindgen_cast_0000000000000001: function(arg0) {
            // Cast intrinsic for `F64 -> Externref`.
            const ret = arg0;
            return ret;
        },
        __wbindgen_cast_0000000000000002: function(arg0, arg1) {
            // Cast intrinsic for `Ref(String) -> Externref`.
            const ret = getStringFromWasm0(arg0, arg1);
            return ret;
        },
        __wbindgen_init_externref_table: function() {
            const table = wasm.__wbindgen_externrefs;
            const offset = table.grow(4);
            table.set(0, undefined);
            table.set(offset + 0, undefined);
            table.set(offset + 1, null);
            table.set(offset + 2, true);
            table.set(offset + 3, false);
        },
    };
    return {
        __proto__: null,
        "./shared_log_rust_bg.js": import0,
    };
}

const NativeRangePlannerFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativerangeplanner_free(ptr, 1));
const NativeSharedLogStateFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativesharedlogstate_free(ptr, 1));

function getArrayU64FromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return getBigUint64ArrayMemory0().subarray(ptr / 8, ptr / 8 + len);
}

let cachedBigUint64ArrayMemory0 = null;
function getBigUint64ArrayMemory0() {
    if (cachedBigUint64ArrayMemory0 === null || cachedBigUint64ArrayMemory0.byteLength === 0) {
        cachedBigUint64ArrayMemory0 = new BigUint64Array(wasm.memory.buffer);
    }
    return cachedBigUint64ArrayMemory0;
}

let cachedDataViewMemory0 = null;
function getDataViewMemory0() {
    if (cachedDataViewMemory0 === null || cachedDataViewMemory0.buffer.detached === true || (cachedDataViewMemory0.buffer.detached === undefined && cachedDataViewMemory0.buffer !== wasm.memory.buffer)) {
        cachedDataViewMemory0 = new DataView(wasm.memory.buffer);
    }
    return cachedDataViewMemory0;
}

function getStringFromWasm0(ptr, len) {
    return decodeText(ptr >>> 0, len);
}

let cachedUint8ArrayMemory0 = null;
function getUint8ArrayMemory0() {
    if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
        cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachedUint8ArrayMemory0;
}

function isLikeNone(x) {
    return x === undefined || x === null;
}

function passStringToWasm0(arg, malloc, realloc) {
    if (realloc === undefined) {
        const buf = cachedTextEncoder.encode(arg);
        const ptr = malloc(buf.length, 1) >>> 0;
        getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
        WASM_VECTOR_LEN = buf.length;
        return ptr;
    }

    let len = arg.length;
    let ptr = malloc(len, 1) >>> 0;

    const mem = getUint8ArrayMemory0();

    let offset = 0;

    for (; offset < len; offset++) {
        const code = arg.charCodeAt(offset);
        if (code > 0x7F) break;
        mem[ptr + offset] = code;
    }
    if (offset !== len) {
        if (offset !== 0) {
            arg = arg.slice(offset);
        }
        ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
        const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
        const ret = cachedTextEncoder.encodeInto(arg, view);

        offset += ret.written;
        ptr = realloc(ptr, len, offset, 1) >>> 0;
    }

    WASM_VECTOR_LEN = offset;
    return ptr;
}

function takeFromExternrefTable0(idx) {
    const value = wasm.__wbindgen_externrefs.get(idx);
    wasm.__externref_table_dealloc(idx);
    return value;
}

let cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
cachedTextDecoder.decode();
const MAX_SAFARI_DECODE_BYTES = 2146435072;
let numBytesDecoded = 0;
function decodeText(ptr, len) {
    numBytesDecoded += len;
    if (numBytesDecoded >= MAX_SAFARI_DECODE_BYTES) {
        cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
        cachedTextDecoder.decode();
        numBytesDecoded = len;
    }
    return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
}

const cachedTextEncoder = new TextEncoder();

if (!('encodeInto' in cachedTextEncoder)) {
    cachedTextEncoder.encodeInto = function (arg, view) {
        const buf = cachedTextEncoder.encode(arg);
        view.set(buf);
        return {
            read: arg.length,
            written: buf.length
        };
    };
}

let WASM_VECTOR_LEN = 0;

let wasmModule, wasmInstance, wasm;
function __wbg_finalize_init(instance, module) {
    wasmInstance = instance;
    wasm = instance.exports;
    wasmModule = module;
    cachedBigUint64ArrayMemory0 = null;
    cachedDataViewMemory0 = null;
    cachedUint8ArrayMemory0 = null;
    wasm.__wbindgen_start();
    return wasm;
}

async function __wbg_load(module, imports) {
    if (typeof Response === 'function' && module instanceof Response) {
        if (typeof WebAssembly.instantiateStreaming === 'function') {
            try {
                return await WebAssembly.instantiateStreaming(module, imports);
            } catch (e) {
                const validResponse = module.ok && expectedResponseType(module.type);

                if (validResponse && module.headers.get('Content-Type') !== 'application/wasm') {
                    console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                } else { throw e; }
            }
        }

        const bytes = await module.arrayBuffer();
        return await WebAssembly.instantiate(bytes, imports);
    } else {
        const instance = await WebAssembly.instantiate(module, imports);

        if (instance instanceof WebAssembly.Instance) {
            return { instance, module };
        } else {
            return instance;
        }
    }

    function expectedResponseType(type) {
        switch (type) {
            case 'basic': case 'cors': case 'default': return true;
        }
        return false;
    }
}

function initSync(module) {
    if (wasm !== undefined) return wasm;


    if (module !== undefined) {
        if (Object.getPrototypeOf(module) === Object.prototype) {
            ({module} = module)
        } else {
            console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
        }
    }

    const imports = __wbg_get_imports();
    if (!(module instanceof WebAssembly.Module)) {
        module = new WebAssembly.Module(module);
    }
    const instance = new WebAssembly.Instance(module, imports);
    return __wbg_finalize_init(instance, module);
}

async function __wbg_init(module_or_path) {
    if (wasm !== undefined) return wasm;


    if (module_or_path !== undefined) {
        if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
            ({module_or_path} = module_or_path)
        } else {
            console.warn('using deprecated parameters for the initialization function; pass a single object instead')
        }
    }

    if (module_or_path === undefined) {
        module_or_path = new URL('shared_log_rust_bg.wasm', import.meta.url);
    }
    const imports = __wbg_get_imports();

    if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
        module_or_path = fetch(module_or_path);
    }

    const { instance, module } = await __wbg_load(await module_or_path, imports);

    return __wbg_finalize_init(instance, module);
}

export { initSync, __wbg_init as default };
