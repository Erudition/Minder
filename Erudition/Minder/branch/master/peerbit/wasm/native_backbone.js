/* @ts-self-types="./native_backbone.d.ts" */

/**
 * A decoded `/peerbit/direct-block` message. Response payload bytes are
 * reported as a range into the input frame so the host can alias them
 * without copying.
 */
export class DirectBlockDecodedMessage {
    static __wrap(ptr) {
        const obj = Object.create(DirectBlockDecodedMessage.prototype);
        obj.__wbg_ptr = ptr;
        DirectBlockDecodedMessageFinalization.register(obj, obj.__wbg_ptr, obj);
        return obj;
    }
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        DirectBlockDecodedMessageFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_directblockdecodedmessage_free(ptr, 0);
    }
    /**
     * @returns {number}
     */
    get bytes_length() {
        const ret = wasm.directblockdecodedmessage_bytes_length(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get bytes_offset() {
        const ret = wasm.directblockdecodedmessage_bytes_offset(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {string}
     */
    get cid() {
        let deferred1_0;
        let deferred1_1;
        try {
            const ret = wasm.directblockdecodedmessage_cid(this.__wbg_ptr);
            deferred1_0 = ret[0];
            deferred1_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @returns {number}
     */
    get variant() {
        const ret = wasm.directblockdecodedmessage_variant(this.__wbg_ptr);
        return ret;
    }
}
if (Symbol.dispose) DirectBlockDecodedMessage.prototype[Symbol.dispose] = DirectBlockDecodedMessage.prototype.free;

/**
 * Eager-block bookkeeping (`_blockCache` in `RemoteBlocks`). The host keeps
 * the block bytes and drops the buffers named by the returned eviction
 * lists, so bytes never cross the boundary.
 */
export class DirectBlockEagerIndex {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        DirectBlockEagerIndexFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_directblockeagerindex_free(ptr, 0);
    }
    /**
     * Track a cid; returns the cids evicted by the insert (ttl/max bound).
     * @param {string} cid
     * @param {number} size
     * @param {number} now_ms
     * @returns {string[]}
     */
    add(cid, size, now_ms) {
        const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directblockeagerindex_add(this.__wbg_ptr, ptr0, len0, size, now_ms);
        var v2 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v2;
    }
    clear() {
        wasm.directblockeagerindex_clear(this.__wbg_ptr);
    }
    /**
     * @param {string} cid
     * @returns {boolean}
     */
    contains(cid) {
        const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directblockeagerindex_contains(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @returns {number}
     */
    current_bytes() {
        const ret = wasm.directblockeagerindex_current_bytes(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {string} cid
     */
    del(cid) {
        const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.directblockeagerindex_del(this.__wbg_ptr, ptr0, len0);
    }
    /**
     * @returns {number}
     */
    len() {
        const ret = wasm.directblockeagerindex_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {number} max_entries
     * @param {number} max_bytes
     * @param {number} ttl_ms
     */
    constructor(max_entries, max_bytes, ttl_ms) {
        const ret = wasm.directblockeagerindex_new(max_entries, max_bytes, ttl_ms);
        this.__wbg_ptr = ret;
        DirectBlockEagerIndexFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * Evict expired entries and return their cids.
     * @param {number} now_ms
     * @returns {string[]}
     */
    sweep(now_ms) {
        const ret = wasm.directblockeagerindex_sweep(this.__wbg_ptr, now_ms);
        var v1 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
}
if (Symbol.dispose) DirectBlockEagerIndex.prototype[Symbol.dispose] = DirectBlockEagerIndex.prototype.free;

/**
 * Provider-hint cache of `RemoteBlocks` (`rememberProvider`/
 * `rememberProviderHints`/lookup). Timestamps are host-supplied wall-clock
 * milliseconds, as in the other DirectStream cores.
 */
export class DirectBlockProviderCache {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        DirectBlockProviderCacheFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_directblockprovidercache_free(ptr, 0);
    }
    clear() {
        wasm.directblockprovidercache_clear(this.__wbg_ptr);
    }
    /**
     * @param {string} cid
     * @param {number} now_ms
     * @returns {string[] | undefined}
     */
    get(cid, now_ms) {
        const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directblockprovidercache_get(this.__wbg_ptr, ptr0, len0, now_ms);
        let v2;
        if (ret[0] !== 0) {
            v2 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        }
        return v2;
    }
    /**
     * @param {string} me
     * @param {number} max_entries
     * @param {number} ttl_ms
     * @param {number} max_providers_per_cid
     */
    constructor(me, max_entries, ttl_ms, max_providers_per_cid) {
        const ptr0 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directblockprovidercache_new(ptr0, len0, max_entries, ttl_ms, max_providers_per_cid);
        this.__wbg_ptr = ret;
        DirectBlockProviderCacheFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {string} cid
     * @param {string[]} providers
     * @param {number} now_ms
     */
    remember_hints(cid, providers, now_ms) {
        const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArrayJsValueToWasm0(providers, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.directblockprovidercache_remember_hints(this.__wbg_ptr, ptr0, len0, ptr1, len1, now_ms);
    }
    /**
     * @param {string} cid
     * @param {string} provider
     * @param {number} now_ms
     */
    remember_provider(cid, provider, now_ms) {
        const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(provider, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.directblockprovidercache_remember_provider(this.__wbg_ptr, ptr0, len0, ptr1, len1, now_ms);
    }
}
if (Symbol.dispose) DirectBlockProviderCache.prototype[Symbol.dispose] = DirectBlockProviderCache.prototype.free;

/**
 * 4-lane WRR outbound scheduler with byte budget (`pushable-lanes.ts`
 * queue core). The host keeps the byte chunks and maps the returned
 * sequence numbers back to them, so bytes never cross the boundary.
 */
export class DirectStreamLanes {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        DirectStreamLanesFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_directstreamlanes_free(ptr, 0);
    }
    clear() {
        wasm.directstreamlanes_clear(this.__wbg_ptr);
    }
    /**
     * @returns {boolean}
     */
    is_empty() {
        const ret = wasm.directstreamlanes_is_empty(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @param {number} lane
     * @returns {number}
     */
    lane_bytes(lane) {
        const ret = wasm.directstreamlanes_lane_bytes(this.__wbg_ptr, lane);
        return ret;
    }
    /**
     * @param {number} lanes
     * @param {number | null} [max_buffered_bytes]
     */
    constructor(lanes, max_buffered_bytes) {
        const ret = wasm.directstreamlanes_new(lanes, !isLikeNone(max_buffered_bytes), isLikeNone(max_buffered_bytes) ? 0 : max_buffered_bytes);
        this.__wbg_ptr = ret;
        DirectStreamLanesFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * Returns the assigned sequence (>= 0), or `-(wouldBeBytes) - 1` when
     * the push would exceed the byte budget (overflow policy 'throw').
     * @param {number} lane
     * @param {number} byte_length
     * @returns {number}
     */
    push(lane, byte_length) {
        const ret = wasm.directstreamlanes_push(this.__wbg_ptr, lane, byte_length);
        return ret;
    }
    /**
     * Next sequence to emit in WRR order, or -1 when empty.
     * @returns {number}
     */
    shift() {
        const ret = wasm.directstreamlanes_shift(this.__wbg_ptr);
        return ret;
    }
    /**
     * @returns {number}
     */
    total_bytes() {
        const ret = wasm.directstreamlanes_total_bytes(this.__wbg_ptr);
        return ret;
    }
}
if (Symbol.dispose) DirectStreamLanes.prototype[Symbol.dispose] = DirectStreamLanes.prototype.free;

/**
 * The DirectStream multi-hop routing table (`stream/src/routes.ts` port).
 * All timestamps/sessions are millisecond wall-clock numbers supplied by
 * the host, so behavior under test clocks matches the TS implementation.
 */
export class DirectStreamRoutes {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        DirectStreamRoutesFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_directstreamroutes_free(ptr, 0);
    }
    /**
     * @param {string} from
     * @param {string} neighbour
     * @param {string} target
     * @param {number} distance
     * @param {number} session
     * @param {number} remote_session
     * @param {number} now_ms
     * @returns {number}
     */
    add(from, neighbour, target, distance, session, remote_session, now_ms) {
        const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(neighbour, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_add(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, distance, session, remote_session, now_ms);
        return ret >>> 0;
    }
    /**
     * @param {number} now_ms
     */
    cleanup_pending(now_ms) {
        wasm.directstreamroutes_cleanup_pending(this.__wbg_ptr, now_ms);
    }
    clear() {
        wasm.directstreamroutes_clear(this.__wbg_ptr);
    }
    /**
     * @param {string} from
     * @returns {number}
     */
    count(from) {
        const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_count(this.__wbg_ptr, ptr0, len0);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    count_all() {
        const ret = wasm.directstreamroutes_count_all(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {string}
     */
    dump_json() {
        let deferred1_0;
        let deferred1_1;
        try {
            const ret = wasm.directstreamroutes_dump_json(this.__wbg_ptr);
            deferred1_0 = ret[0];
            deferred1_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @param {string} from
     * @param {string} target
     * @returns {string | undefined}
     */
    find_neighbor_json(from, target) {
        const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_find_neighbor_json(this.__wbg_ptr, ptr0, len0, ptr1, len1);
        let v3;
        if (ret[0] !== 0) {
            v3 = getStringFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v3;
    }
    /**
     * @param {string} peer
     * @returns {string[]}
     */
    get_dependent(peer) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_get_dependent(this.__wbg_ptr, ptr0, len0);
        var v2 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v2;
    }
    /**
     * @param {string} from
     * @param {string[]} tos
     * @param {number} redundancy
     * @returns {string | undefined}
     */
    get_fanout_json(from, tos, redundancy) {
        const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArrayJsValueToWasm0(tos, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_get_fanout_json(this.__wbg_ptr, ptr0, len0, ptr1, len1, redundancy);
        let v3;
        if (ret[0] !== 0) {
            v3 = getStringFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v3;
    }
    /**
     * @param {string[]} neighbours
     * @returns {string[]}
     */
    get_prunable(neighbours) {
        const ptr0 = passArrayJsValueToWasm0(neighbours, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_get_prunable(this.__wbg_ptr, ptr0, len0);
        var v2 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v2;
    }
    /**
     * @param {string} from
     * @param {string} target
     * @param {number} now_ms
     * @returns {string}
     */
    get_route_hints_json(from, target, now_ms) {
        let deferred3_0;
        let deferred3_1;
        try {
            const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len0 = WASM_VECTOR_LEN;
            const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len1 = WASM_VECTOR_LEN;
            const ret = wasm.directstreamroutes_get_route_hints_json(this.__wbg_ptr, ptr0, len0, ptr1, len1, now_ms);
            deferred3_0 = ret[0];
            deferred3_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
        }
    }
    /**
     * @returns {number}
     */
    get_route_max_retention_period() {
        const ret = wasm.directstreamroutes_get_route_max_retention_period(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {string} remote
     * @returns {number | undefined}
     */
    get_session(remote) {
        const ptr0 = passStringToWasm0(remote, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_get_session(this.__wbg_ptr, ptr0, len0);
        return ret[0] === 0 ? undefined : ret[1];
    }
    /**
     * @returns {boolean}
     */
    has_pending_cleanup() {
        const ret = wasm.directstreamroutes_has_pending_cleanup(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @param {string} target
     * @returns {boolean}
     */
    has_target(target) {
        const ptr0 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_has_target(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {string} from
     * @param {string} target
     * @param {number | null} [max_distance]
     * @returns {boolean}
     */
    is_reachable(from, target, max_distance) {
        const ptr0 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_is_reachable(this.__wbg_ptr, ptr0, len0, ptr1, len1, !isLikeNone(max_distance), isLikeNone(max_distance) ? 0 : max_distance);
        return ret !== 0;
    }
    /**
     * @param {string} me
     * @param {number | null} [route_max_retention_period_ms]
     * @param {number | null} [max_from_entries]
     * @param {number | null} [max_targets_per_from]
     * @param {number | null} [max_relays_per_target]
     */
    constructor(me, route_max_retention_period_ms, max_from_entries, max_targets_per_from, max_relays_per_target) {
        const ptr0 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_new(ptr0, len0, !isLikeNone(route_max_retention_period_ms), isLikeNone(route_max_retention_period_ms) ? 0 : route_max_retention_period_ms, isLikeNone(max_from_entries) ? Number.MAX_SAFE_INTEGER : (max_from_entries) >>> 0, isLikeNone(max_targets_per_from) ? Number.MAX_SAFE_INTEGER : (max_targets_per_from) >>> 0, isLikeNone(max_relays_per_target) ? Number.MAX_SAFE_INTEGER : (max_relays_per_target) >>> 0);
        this.__wbg_ptr = ret;
        DirectStreamRoutesFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {string} target
     * @returns {string[]}
     */
    remove(target) {
        const ptr0 = passStringToWasm0(target, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_remove(this.__wbg_ptr, ptr0, len0);
        var v2 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v2;
    }
    /**
     * @param {string} neighbour
     */
    remove_neighbour(neighbour) {
        const ptr0 = passStringToWasm0(neighbour, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.directstreamroutes_remove_neighbour(this.__wbg_ptr, ptr0, len0);
    }
    /**
     * @param {number} ms
     */
    set_route_max_retention_period(ms) {
        wasm.directstreamroutes_set_route_max_retention_period(this.__wbg_ptr, ms);
    }
    /**
     * @param {string} remote
     * @param {number | null} [session]
     * @returns {boolean}
     */
    update_session(remote, session) {
        const ptr0 = passStringToWasm0(remote, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamroutes_update_session(this.__wbg_ptr, ptr0, len0, !isLikeNone(session), isLikeNone(session) ? 0 : session);
        return ret !== 0;
    }
}
if (Symbol.dispose) DirectStreamRoutes.prototype[Symbol.dispose] = DirectStreamRoutes.prototype.free;

/**
 * Seen-cache dedup counter (`modifySeenCache` semantics).
 */
export class DirectStreamSeenCache {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        DirectStreamSeenCacheFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_directstreamseencache_free(ptr, 0);
    }
    clear() {
        wasm.directstreamseencache_clear(this.__wbg_ptr);
    }
    /**
     * `key_kind` 0 = message id (first 33 frame bytes), 1 = sha256 of the
     * whole frame (the ACK path). Returns the seen-before counter.
     * @param {Uint8Array} frame
     * @param {number} key_kind
     * @param {number} now_ms
     * @returns {number}
     */
    modify(frame, key_kind, now_ms) {
        const ptr0 = passArray8ToWasm0(frame, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.directstreamseencache_modify(this.__wbg_ptr, ptr0, len0, key_kind, now_ms);
        return ret >>> 0;
    }
    /**
     * @param {number} max
     * @param {number} ttl_ms
     */
    constructor(max, ttl_ms) {
        const ret = wasm.directstreamseencache_new(max, ttl_ms);
        this.__wbg_ptr = ret;
        DirectStreamSeenCacheFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
}
if (Symbol.dispose) DirectStreamSeenCache.prototype[Symbol.dispose] = DirectStreamSeenCache.prototype.free;

/**
 * A decoded `/peerbit/fanout-tree` control frame. One shared shape covers
 * every message kind; the per-kind `ft_decode_*` function documents which
 * fields it populates. Entry lists (tracker reply, provider reply/notify)
 * are flattened into parallel arrays with `entry_addr_counts` delimiting
 * each entry's slice of `entry_addrs`.
 */
export class FanoutTreeDecodedFrame {
    static __wrap(ptr) {
        const obj = Object.create(FanoutTreeDecodedFrame.prototype);
        obj.__wbg_ptr = ptr;
        FanoutTreeDecodedFrameFinalization.register(obj, obj.__wbg_ptr, obj);
        return obj;
    }
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        FanoutTreeDecodedFrameFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_fanouttreedecodedframe_free(ptr, 0);
    }
    /**
     * @returns {bigint}
     */
    get ack_token() {
        const ret = wasm.fanouttreedecodedframe_ack_token(this.__wbg_ptr);
        return BigInt.asUintN(64, ret);
    }
    /**
     * @returns {Array<any>}
     */
    get addrs() {
        const ret = wasm.fanouttreedecodedframe_addrs(this.__wbg_ptr);
        return ret;
    }
    /**
     * @returns {number}
     */
    get bid_per_byte() {
        const ret = wasm.fanouttreedecodedframe_bid_per_byte(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get children() {
        const ret = wasm.fanouttreedecodedframe_children(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get data_write_drops() {
        const ret = wasm.fanouttreedecodedframe_data_write_drops(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get dropped_forwards() {
        const ret = wasm.fanouttreedecodedframe_dropped_forwards(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {Uint32Array}
     */
    get entry_addr_counts() {
        const ret = wasm.fanouttreedecodedframe_entry_addr_counts(this.__wbg_ptr);
        var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {Array<any>}
     */
    get entry_addrs() {
        const ret = wasm.fanouttreedecodedframe_entry_addrs(this.__wbg_ptr);
        return ret;
    }
    /**
     * @returns {Uint32Array}
     */
    get entry_bids() {
        const ret = wasm.fanouttreedecodedframe_entry_bids(this.__wbg_ptr);
        var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {Uint32Array}
     */
    get entry_free_slots() {
        const ret = wasm.fanouttreedecodedframe_entry_free_slots(this.__wbg_ptr);
        var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {string[]}
     */
    get entry_hashes() {
        const ret = wasm.fanouttreedecodedframe_entry_hashes(this.__wbg_ptr);
        var v1 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {Uint32Array}
     */
    get entry_levels() {
        const ret = wasm.fanouttreedecodedframe_entry_levels(this.__wbg_ptr);
        var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {number}
     */
    get event() {
        const ret = wasm.fanouttreedecodedframe_event(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get flags() {
        const ret = wasm.fanouttreedecodedframe_flags(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get free_slots() {
        const ret = wasm.fanouttreedecodedframe_free_slots(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {boolean}
     */
    get has_ack() {
        const ret = wasm.fanouttreedecodedframe_has_ack(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {boolean}
     */
    get has_have_range() {
        const ret = wasm.fanouttreedecodedframe_has_have_range(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {boolean}
     */
    get has_reply_route() {
        const ret = wasm.fanouttreedecodedframe_has_reply_route(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {boolean}
     */
    get has_text() {
        const ret = wasm.fanouttreedecodedframe_has_text(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {number}
     */
    get have_from() {
        const ret = wasm.fanouttreedecodedframe_have_from(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get have_to_exclusive() {
        const ret = wasm.fanouttreedecodedframe_have_to_exclusive(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get level() {
        const ret = wasm.fanouttreedecodedframe_level(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get max_children() {
        const ret = wasm.fanouttreedecodedframe_max_children(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get min_free_slots() {
        const ret = wasm.fanouttreedecodedframe_min_free_slots(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get missing_seqs() {
        const ret = wasm.fanouttreedecodedframe_missing_seqs(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get payload_offset() {
        const ret = wasm.fanouttreedecodedframe_payload_offset(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get reason() {
        const ret = wasm.fanouttreedecodedframe_reason(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {string[]}
     */
    get reply_route() {
        const ret = wasm.fanouttreedecodedframe_reply_route(this.__wbg_ptr);
        var v1 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {number}
     */
    get req_id() {
        const ret = wasm.fanouttreedecodedframe_req_id(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get reservation_token() {
        const ret = wasm.fanouttreedecodedframe_reservation_token(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {boolean}
     */
    get reserve_root_capacity() {
        const ret = wasm.fanouttreedecodedframe_reserve_root_capacity(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {string[]}
     */
    get route() {
        const ret = wasm.fanouttreedecodedframe_route(this.__wbg_ptr);
        var v1 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {number}
     */
    get seed() {
        const ret = wasm.fanouttreedecodedframe_seed(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {Uint32Array}
     */
    get seqs() {
        const ret = wasm.fanouttreedecodedframe_seqs(this.__wbg_ptr);
        var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {string}
     */
    get text() {
        let deferred1_0;
        let deferred1_1;
        try {
            const ret = wasm.fanouttreedecodedframe_text(this.__wbg_ptr);
            deferred1_0 = ret[0];
            deferred1_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @returns {number}
     */
    get ttl_ms() {
        const ret = wasm.fanouttreedecodedframe_ttl_ms(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get want() {
        const ret = wasm.fanouttreedecodedframe_want(this.__wbg_ptr);
        return ret >>> 0;
    }
}
if (Symbol.dispose) FanoutTreeDecodedFrame.prototype[Symbol.dispose] = FanoutTreeDecodedFrame.prototype.free;

/**
 * Stateless Wasm boundary for the canonical journal codec. All u64 values are
 * decimal strings so JavaScript never rounds an LSN, sequence, or fence epoch.
 */
export class NativeDurabilityJournalCodec {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativeDurabilityJournalCodecFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativedurabilityjournalcodec_free(ptr, 0);
    }
    /**
     * @param {string} record_lsn
     * @param {string} tx_sequence
     * @param {string} writer_epoch
     * @param {string} writer_owner_id
     * @param {string} writer_domain_id
     * @param {number} phase
     * @param {number} operation_kind
     * @param {Uint8Array} program_id
     * @param {string} transaction_id
     * @param {Uint8Array} plan_digest
     * @param {Uint8Array} payload
     * @returns {Uint8Array}
     */
    encodeFrame(record_lsn, tx_sequence, writer_epoch, writer_owner_id, writer_domain_id, phase, operation_kind, program_id, transaction_id, plan_digest, payload) {
        const ptr0 = passStringToWasm0(record_lsn, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(tx_sequence, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(writer_epoch, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(writer_owner_id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(writer_domain_id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(transaction_id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativedurabilityjournalcodec_encodeFrame(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, phase, operation_kind, program_id, ptr5, len5, plan_digest, payload);
        if (ret[3]) {
            throw takeFromExternrefTable0(ret[2]);
        }
        var v7 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v7;
    }
    constructor() {
        const ret = wasm.nativedurabilityjournalcodec_new();
        this.__wbg_ptr = ret;
        NativeDurabilityJournalCodecFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {Uint8Array} bytes
     * @param {string} checkpoint_lsn
     * @param {string} checkpoint_tx_sequence_highwater
     * @param {Uint8Array} expected_program_id
     * @param {string} expected_writer_domain_id
     * @param {string} checkpoint_writer_epoch
     * @param {string | null | undefined} checkpoint_writer_owner_id
     * @param {string} current_writer_epoch
     * @param {string} current_writer_owner_id
     * @param {Array<any>} retained_transaction_rows
     * @returns {Array<any>}
     */
    scan(bytes, checkpoint_lsn, checkpoint_tx_sequence_highwater, expected_program_id, expected_writer_domain_id, checkpoint_writer_epoch, checkpoint_writer_owner_id, current_writer_epoch, current_writer_owner_id, retained_transaction_rows) {
        const ptr0 = passStringToWasm0(checkpoint_lsn, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(checkpoint_tx_sequence_highwater, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(expected_writer_domain_id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(checkpoint_writer_epoch, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        var ptr4 = isLikeNone(checkpoint_writer_owner_id) ? 0 : passStringToWasm0(checkpoint_writer_owner_id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(current_writer_epoch, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ptr6 = passStringToWasm0(current_writer_owner_id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len6 = WASM_VECTOR_LEN;
        const ret = wasm.nativedurabilityjournalcodec_scan(this.__wbg_ptr, bytes, ptr0, len0, ptr1, len1, expected_program_id, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, ptr6, len6, retained_transaction_rows);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
}
if (Symbol.dispose) NativeDurabilityJournalCodec.prototype[Symbol.dispose] = NativeDurabilityJournalCodec.prototype.free;

export class NativeEntryV0PlainBuilder {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativeEntryV0PlainBuilderFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativeentryv0plainbuilder_free(ptr, 0);
    }
    /**
     * @param {Uint8Array} clock_id
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     */
    constructor(clock_id, private_key, public_key) {
        const ret = wasm.nativeentryv0plainbuilder_new(clock_id, private_key, public_key);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        this.__wbg_ptr = ret[0];
        NativeEntryV0PlainBuilderFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
}
if (Symbol.dispose) NativeEntryV0PlainBuilder.prototype[Symbol.dispose] = NativeEntryV0PlainBuilder.prototype.free;

export class NativeLogBlockStore {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativeLogBlockStoreFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativelogblockstore_free(ptr, 0);
    }
    clear() {
        wasm.nativelogblockstore_clear(this.__wbg_ptr);
    }
    /**
     * @param {string} key
     * @returns {boolean}
     */
    delete(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogblockstore_delete(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} keys
     * @returns {number}
     */
    delete_many(keys) {
        const ret = wasm.nativelogblockstore_delete_many(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @returns {Array<any>}
     */
    entries() {
        const ret = wasm.nativelogblockstore_entries(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {string} key
     * @returns {Uint8Array | undefined}
     */
    get(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogblockstore_get(this.__wbg_ptr, ptr0, len0);
        let v2;
        if (ret[0] !== 0) {
            v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v2;
    }
    /**
     * @param {Array<any>} keys
     * @returns {Array<any>}
     */
    get_many(keys) {
        const ret = wasm.nativelogblockstore_get_many(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} key
     * @returns {boolean}
     */
    has(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogblockstore_has(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} keys
     * @returns {Array<any>}
     */
    has_many(keys) {
        const ret = wasm.nativelogblockstore_has_many(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {number}
     */
    len() {
        const ret = wasm.nativelogblockstore_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    constructor() {
        const ret = wasm.nativelogblockstore_new();
        this.__wbg_ptr = ret;
        NativeLogBlockStoreFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {string} key
     * @param {Uint8Array} value
     */
    put(key, value) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(value, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.nativelogblockstore_put(this.__wbg_ptr, ptr0, len0, ptr1, len1);
    }
    /**
     * @param {Array<any>} keys
     * @param {Array<any>} values
     */
    put_many(keys, values) {
        const ret = wasm.nativelogblockstore_put_many(this.__wbg_ptr, keys, values);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @returns {number}
     */
    size() {
        const ret = wasm.nativelogblockstore_size(this.__wbg_ptr);
        return ret;
    }
}
if (Symbol.dispose) NativeLogBlockStore.prototype[Symbol.dispose] = NativeLogBlockStore.prototype.free;

export class NativeLogIndex {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativeLogIndexFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativelogindex_free(ptr, 0);
    }
    /**
     * @param {string} hash
     * @returns {Array<any>}
     */
    child_join_entries(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_child_join_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string} hash
     * @returns {Array<any>}
     */
    children(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_children(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    clear() {
        wasm.nativelogindex_clear(this.__wbg_ptr);
    }
    /**
     * @param {string} next
     * @param {string | null} [exclude_hash]
     * @returns {number}
     */
    count_has_next(next, exclude_hash) {
        const ptr0 = passStringToWasm0(next, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(exclude_hash) ? 0 : passStringToWasm0(exclude_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_count_has_next(this.__wbg_ptr, ptr0, len0, ptr1, len1);
        return ret >>> 0;
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    delete(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_delete(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @returns {number}
     */
    delete_many(hashes) {
        const ret = wasm.nativelogindex_delete_many(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    entry_metadata_batch(hashes) {
        const ret = wasm.nativelogindex_entry_metadata_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    entry_metadata_hints_batch(hashes) {
        const ret = wasm.nativelogindex_entry_metadata_hints_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    has(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_has(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} gids
     * @returns {boolean}
     */
    has_any_head(gids) {
        const ret = wasm.nativelogindex_has_any_head(this.__wbg_ptr, gids);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} gid_sets
     * @returns {Array<any>}
     */
    has_any_head_batch(gid_sets) {
        const ret = wasm.nativelogindex_has_any_head_batch(this.__wbg_ptr, gid_sets);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string | null} [gid]
     * @returns {boolean}
     */
    has_head(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_has_head(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    has_many(hashes) {
        const ret = wasm.nativelogindex_has_many(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    head_data_entries(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_head_data_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    head_entries(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_head_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    head_join_entries(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_head_join_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    heads(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_heads(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @returns {number}
     */
    len() {
        const ret = wasm.nativelogindex_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {string | null} [gid]
     * @returns {any}
     */
    max_head_data_u32(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_max_head_data_u32(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {Array<any>} gids
     * @returns {Array<any>}
     */
    max_head_data_u32_batch(gids) {
        const ret = wasm.nativelogindex_max_head_data_u32_batch(this.__wbg_ptr, gids);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    constructor() {
        const ret = wasm.nativelogindex_new();
        this.__wbg_ptr = ret;
        NativeLogIndexFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @returns {any}
     */
    newest_hash() {
        const ret = wasm.nativelogindex_newest_hash(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {number} limit
     * @returns {Array<any>}
     */
    oldest_entries(limit) {
        const ret = wasm.nativelogindex_oldest_entries(this.__wbg_ptr, limit);
        return ret;
    }
    /**
     * @returns {any}
     */
    oldest_hash() {
        const ret = wasm.nativelogindex_oldest_hash(this.__wbg_ptr);
        return ret;
    }
    /**
     * @returns {number}
     */
    payload_size_sum() {
        const ret = wasm.nativelogindex_payload_size_sum(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {Array<any>} from
     * @param {boolean} skip_first
     * @returns {Array<any>}
     */
    plan_delete_recursively(from, skip_first) {
        const ret = wasm.nativelogindex_plan_delete_recursively(this.__wbg_ptr, from, skip_first);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {boolean} reset
     * @param {string | null} [gid]
     * @param {bigint | null} [wall_time]
     * @param {number | null} [logical]
     * @returns {Array<any>}
     */
    plan_join(hash, next, entry_type, reset, gid, wall_time, logical) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_plan_join(this.__wbg_ptr, ptr0, len0, next, entry_type, reset, ptr1, len1, !isLikeNone(wall_time), isLikeNone(wall_time) ? BigInt(0) : wall_time, isLikeNone(logical) ? Number.MAX_SAFE_INTEGER : (logical) >>> 0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} nexts
     * @param {Uint8Array} entry_types
     * @param {boolean} reset
     * @param {Array<any>} gids
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {boolean} cut_check
     * @returns {Array<any>}
     */
    plan_join_batch(hashes, nexts, entry_types, reset, gids, wall_times, logicals, cut_check) {
        const ret = wasm.nativelogindex_plan_join_batch(this.__wbg_ptr, hashes, nexts, entry_types, reset, gids, wall_times, logicals, cut_check);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Uint8Array} clock_id
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {string} gid
     * @param {Array<any>} initial_next
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_chain_and_put(clock_id, private_key, public_key, wall_times, logicals, gid, initial_next, entry_type, meta_datas, payload_datas) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_chain_and_put(this.__wbg_ptr, clock_id, private_key, public_key, wall_times, logicals, ptr0, len0, initial_next, entry_type, meta_datas, payload_datas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeLogBlockStore} block_store
     * @param {Uint8Array} clock_id
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {string} gid
     * @param {Array<any>} initial_next
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_chain_commit_blocks_and_put(block_store, clock_id, private_key, public_key, wall_times, logicals, gid, initial_next, entry_type, meta_datas, payload_datas) {
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_chain_commit_blocks_and_put(this.__wbg_ptr, block_store.__wbg_ptr, clock_id, private_key, public_key, wall_times, logicals, ptr0, len0, initial_next, entry_type, meta_datas, payload_datas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} gids
     * @param {Array<any>} nexts
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entries_commit_blocks_and_put_with_builder(builder, block_store, wall_times, logicals, gids, nexts, entry_type, meta_datas, payload_datas) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entries_commit_blocks_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_times, logicals, gids, nexts, entry_type, meta_datas, payload_datas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entries_no_next_commit_blocks_and_put_with_builder(builder, block_store, wall_times, logicals, gids, entry_type, meta_datas, payload_datas) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entries_no_next_commit_blocks_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_times, logicals, gids, entry_type, meta_datas, payload_datas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Uint8Array} clock_id
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_and_put(clock_id, private_key, public_key, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_and_put(this.__wbg_ptr, clock_id, private_key, public_key, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_and_put_with_builder(builder, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeLogBlockStore} block_store
     * @param {Uint8Array} clock_id
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_block_and_put(block_store, clock_id, private_key, public_key, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_block_and_put(this.__wbg_ptr, block_store.__wbg_ptr, clock_id, private_key, public_key, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_block_and_put_with_builder(builder, block_store, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_block_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_facts_and_put_with_builder(builder, block_store, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_facts_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_facts_trim_and_put_with_builder(builder, block_store, wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_facts_trim_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_facts_trim_hashes_and_put_with_builder(builder, block_store, wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_facts_trim_hashes_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_no_next_facts_and_put_with_builder(builder, block_store, wall_time, logical, gid, entry_type, meta_data, payload_data) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_no_next_facts_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_no_next_facts_trim_and_put_with_builder(builder, block_store, wall_time, logical, gid, entry_type, meta_data, payload_data, trim_length_to) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_no_next_facts_trim_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_commit_no_next_facts_trim_hashes_and_put_with_builder(builder, block_store, wall_time, logical, gid, entry_type, meta_data, payload_data, trim_length_to) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_commit_no_next_facts_trim_hashes_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_storage_and_put_with_builder(builder, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_storage_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_storage_commit_block_and_put_with_builder(builder, block_store, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_storage_commit_block_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {NativeLogBlockStore} block_store
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_storage_commit_block_trim_and_put_with_builder(builder, block_store, wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        _assertClass(block_store, NativeLogBlockStore);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_storage_commit_block_trim_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, block_store.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_storage_facts_and_put_with_builder(builder, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_storage_facts_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_storage_facts_trim_and_put_with_builder(builder, wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_storage_facts_trim_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {NativeEntryV0PlainBuilder} builder
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_entry_v0_plain_entry_storage_trim_and_put_with_builder(builder, wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to) {
        _assertClass(builder, NativeEntryV0PlainBuilder);
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_prepare_entry_v0_plain_entry_storage_trim_and_put_with_builder(this.__wbg_ptr, builder.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {number} payload_size
     * @param {boolean} head
     * @param {any} data
     */
    put(hash, gid, next, entry_type, wall_time, logical, payload_size, head, data) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_put(this.__wbg_ptr, ptr0, len0, ptr1, len1, next, entry_type, wall_time, logical, payload_size, head, data);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} gid
     * @param {Array<any>} initial_next
     * @param {number} entry_type
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Uint32Array} payload_sizes
     * @param {Array<any>} datas
     */
    put_append_chain(hashes, gid, initial_next, entry_type, wall_times, logicals, payload_sizes, datas) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_put_append_chain(this.__wbg_ptr, hashes, ptr0, len0, initial_next, entry_type, wall_times, logicals, payload_sizes, datas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} gids
     * @param {Array<any>} nexts
     * @param {Uint8Array} entry_types
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Uint32Array} payload_sizes
     * @param {Uint8Array} heads
     * @param {Array<any>} datas
     */
    put_many(hashes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas) {
        const ret = wasm.nativelogindex_put_many(this.__wbg_ptr, hashes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} gid
     * @param {Array<any>} next
     * @param {string | null} [exclude_hash]
     * @returns {Array<any>}
     */
    shadowed_gids(gid, next, exclude_hash) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(exclude_hash) ? 0 : passStringToWasm0(exclude_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_shadowed_gids(this.__wbg_ptr, ptr0, len0, next, ptr1, len1);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    unique_reference_gid_rows_batch(hashes) {
        const ret = wasm.nativelogindex_unique_reference_gid_rows_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {any}
     */
    unique_reference_gid_rows_flat_batch(hashes) {
        const ret = wasm.nativelogindex_unique_reference_gid_rows_flat_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @returns {any}
     */
    unique_reference_gids(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativelogindex_unique_reference_gids(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
}
if (Symbol.dispose) NativeLogIndex.prototype[Symbol.dispose] = NativeLogIndex.prototype.free;

export class NativePeerbitBackbone {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativePeerbitBackboneFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativepeerbitbackbone_free(ptr, 0);
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
        const ret = wasm.nativepeerbitbackbone_add_gid_peers(this.__wbg_ptr, ptr0, len0, peers, reset);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @returns {Array<any>}
     */
    append_profile() {
        const ret = wasm.nativepeerbitbackbone_append_profile(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {number} iterations
     * @param {bigint} wall_time_start
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {string} self_hash
     * @param {boolean} use_document_index
     * @param {number} document_byte_element_index_limit
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    benchmark_plain_committed_no_next_storage_append_transaction_loop(iterations, wall_time_start, payload_data, replicas, self_hash, use_document_index, document_byte_element_index_limit, trim_length_to) {
        const ptr0 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_benchmark_plain_committed_no_next_storage_append_transaction_loop(this.__wbg_ptr, iterations, wall_time_start, payload_data, replicas, ptr0, len0, use_document_index, document_byte_element_index_limit, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} key
     * @returns {boolean}
     */
    block_delete(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_block_delete(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} keys
     * @returns {number}
     */
    block_delete_many(keys) {
        const ret = wasm.nativepeerbitbackbone_block_delete_many(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @returns {Array<any>}
     */
    block_entries() {
        const ret = wasm.nativepeerbitbackbone_block_entries(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {string} key
     * @returns {Uint8Array | undefined}
     */
    block_get(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_block_get(this.__wbg_ptr, ptr0, len0);
        let v2;
        if (ret[0] !== 0) {
            v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v2;
    }
    /**
     * @param {Array<any>} keys
     * @returns {Array<any>}
     */
    block_get_many(keys) {
        const ret = wasm.nativepeerbitbackbone_block_get_many(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} keys
     * @returns {Array<any>}
     */
    block_has_many(keys) {
        const ret = wasm.nativepeerbitbackbone_block_has_many(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {number}
     */
    block_len() {
        const ret = wasm.nativepeerbitbackbone_block_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {string} key
     * @param {Uint8Array} value
     */
    block_put(key, value) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(value, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.nativepeerbitbackbone_block_put(this.__wbg_ptr, ptr0, len0, ptr1, len1);
    }
    /**
     * @param {Array<any>} keys
     * @param {Array<any>} values
     */
    block_put_many(keys, values) {
        const ret = wasm.nativepeerbitbackbone_block_put_many(this.__wbg_ptr, keys, values);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @returns {number}
     */
    block_size() {
        const ret = wasm.nativepeerbitbackbone_block_size(this.__wbg_ptr);
        return ret;
    }
    clear() {
        wasm.nativepeerbitbackbone_clear(this.__wbg_ptr);
    }
    clear_coordinate_journal() {
        wasm.nativepeerbitbackbone_clear_coordinate_journal(this.__wbg_ptr);
    }
    /**
     * @param {number} byte_len
     * @param {number} record_count
     */
    clear_coordinate_journal_prefix(byte_len, record_count) {
        wasm.nativepeerbitbackbone_clear_coordinate_journal_prefix(this.__wbg_ptr, byte_len, record_count);
    }
    clear_document_index() {
        wasm.nativepeerbitbackbone_clear_document_index(this.__wbg_ptr);
    }
    clear_document_journal() {
        wasm.nativepeerbitbackbone_clear_document_journal(this.__wbg_ptr);
    }
    /**
     * @param {number} byte_len
     * @param {number} record_count
     */
    clear_document_journal_prefix(byte_len, record_count) {
        wasm.nativepeerbitbackbone_clear_document_journal_prefix(this.__wbg_ptr, byte_len, record_count);
    }
    clear_document_signer_journal() {
        wasm.nativepeerbitbackbone_clear_document_signer_journal(this.__wbg_ptr);
    }
    /**
     * @param {number} byte_len
     * @param {number} record_count
     */
    clear_document_signer_journal_prefix(byte_len, record_count) {
        wasm.nativepeerbitbackbone_clear_document_signer_journal_prefix(this.__wbg_ptr, byte_len, record_count);
    }
    clear_entry_coordinates() {
        wasm.nativepeerbitbackbone_clear_entry_coordinates(this.__wbg_ptr);
    }
    clear_entry_known_peers() {
        wasm.nativepeerbitbackbone_clear_entry_known_peers(this.__wbg_ptr);
    }
    clear_gid_peers() {
        wasm.nativepeerbitbackbone_clear_gid_peers(this.__wbg_ptr);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {number}
     */
    clear_prepared_raw_receive_entries(hashes) {
        const ret = wasm.nativepeerbitbackbone_clear_prepared_raw_receive_entries(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    clear_shared_log() {
        wasm.nativepeerbitbackbone_clear_shared_log(this.__wbg_ptr);
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
        const ret = wasm.nativepeerbitbackbone_commit_entry_coordinates(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, coordinates, next_hashes, assigned_to_range_boundary, requested_replicas);
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
        const ret = wasm.nativepeerbitbackbone_commit_entry_coordinates_batch(this.__wbg_ptr, hashes, gids, hash_numbers, coordinate_batches, next_hash_batches, assigned_to_range_boundaries, requested_replicas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} gids
     * @param {BigUint64Array} hash_numbers
     * @param {Uint32Array} coordinate_counts
     * @param {BigUint64Array} coordinates
     * @param {Array<any>} next_hash_batches
     * @param {Uint8Array} assigned_to_range_boundaries
     * @param {Uint32Array} requested_replicas
     */
    commit_entry_coordinates_batch_u64(hashes, gids, hash_numbers, coordinate_counts, coordinates, next_hash_batches, assigned_to_range_boundaries, requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_entry_coordinates_batch_u64(this.__wbg_ptr, hashes, gids, hash_numbers, coordinate_counts, coordinates, next_hash_batches, assigned_to_range_boundaries, requested_replicas);
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
        const ret = wasm.nativepeerbitbackbone_commit_local_append_for_gid_compact(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, next_hashes, delete_hashes, replicas, role_age_ms, ptr3, len3, peer_filter, expand_peer_filter, ptr4, len4, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} block_bytes
     * @param {Array<any>} gids
     * @param {Array<any>} nexts
     * @param {Uint8Array} entry_types
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Uint32Array} payload_sizes
     * @param {Uint8Array} heads
     * @param {Array<any>} datas
     */
    commit_log_blocks_and_graph_batch(hashes, block_bytes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas) {
        const ret = wasm.nativepeerbitbackbone_commit_log_blocks_and_graph_batch(this.__wbg_ptr, hashes, block_bytes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} block_bytes
     * @param {Array<any>} gids
     * @param {Array<any>} nexts
     * @param {Uint8Array} entry_types
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Uint32Array} payload_sizes
     * @param {Uint8Array} heads
     * @param {Array<any>} datas
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {Array<any>} coordinate_hash_numbers
     * @param {Array<any>} coordinate_batches
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Array<any>} coordinate_requested_replicas
     */
    commit_log_blocks_graph_and_coordinates_batch(hashes, block_bytes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_log_blocks_graph_and_coordinates_batch(this.__wbg_ptr, hashes, block_bytes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {Array<any>} coordinate_hash_numbers
     * @param {Array<any>} coordinate_batches
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Array<any>} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_prepared_raw_receive_batch(hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_prepared_raw_receive_batch(this.__wbg_ptr, hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {BigUint64Array} coordinate_hash_numbers
     * @param {Uint32Array} coordinate_counts
     * @param {BigUint64Array} coordinates
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Uint32Array} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_prepared_raw_receive_batch_u64(hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_prepared_raw_receive_batch_u64(this.__wbg_ptr, hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {Array<any>} coordinate_hash_numbers
     * @param {Array<any>} coordinate_batches
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Array<any>} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_prepared_raw_receive_join_batch(hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_prepared_raw_receive_join_batch(this.__wbg_ptr, hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {BigUint64Array} coordinate_hash_numbers
     * @param {Uint32Array} coordinate_counts
     * @param {BigUint64Array} coordinates
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Uint32Array} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_prepared_raw_receive_join_batch_u64(hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_prepared_raw_receive_join_batch_u64(this.__wbg_ptr, hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {Array<any>} coordinate_hash_numbers
     * @param {Array<any>} coordinate_batches
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Array<any>} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_verified_all_prepared_raw_receive_join_batch(hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_verified_all_prepared_raw_receive_join_batch(this.__wbg_ptr, hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {BigUint64Array} coordinate_hash_numbers
     * @param {Uint32Array} coordinate_counts
     * @param {BigUint64Array} coordinates
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Uint32Array} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_verified_all_prepared_raw_receive_join_batch_u64(hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_verified_all_prepared_raw_receive_join_batch_u64(this.__wbg_ptr, hashes, heads, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} verify_hashes
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {Array<any>} coordinate_hash_numbers
     * @param {Array<any>} coordinate_batches
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Array<any>} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_verified_prepared_raw_receive_join_batch(hashes, heads, verify_hashes, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_verified_prepared_raw_receive_join_batch(this.__wbg_ptr, hashes, heads, verify_hashes, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_batches, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Uint8Array} heads
     * @param {Array<any>} verify_hashes
     * @param {Array<any>} coordinate_hashes
     * @param {Array<any>} coordinate_gids
     * @param {BigUint64Array} coordinate_hash_numbers
     * @param {Uint32Array} coordinate_counts
     * @param {BigUint64Array} coordinates
     * @param {Array<any>} coordinate_next_hash_batches
     * @param {Uint8Array} coordinate_assigned_to_range_boundaries
     * @param {Uint32Array} coordinate_requested_replicas
     * @returns {boolean}
     */
    commit_verified_prepared_raw_receive_join_batch_u64(hashes, heads, verify_hashes, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas) {
        const ret = wasm.nativepeerbitbackbone_commit_verified_prepared_raw_receive_join_batch_u64(this.__wbg_ptr, hashes, heads, verify_hashes, coordinate_hashes, coordinate_gids, coordinate_hash_numbers, coordinate_counts, coordinates, coordinate_next_hash_batches, coordinate_assigned_to_range_boundaries, coordinate_requested_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Uint8Array} schema_ir_bytes
     * @returns {Array<any>}
     */
    configure_document_schema_ir(schema_ir_bytes) {
        const ptr0 = passArray8ToWasm0(schema_ir_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_configure_document_schema_ir(this.__wbg_ptr, ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    coordinate_index_has_hash(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_coordinate_index_has_hash(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @returns {number}
     */
    coordinate_index_len() {
        const ret = wasm.nativepeerbitbackbone_coordinate_index_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {Uint8Array}
     */
    coordinate_journal() {
        const ret = wasm.nativepeerbitbackbone_coordinate_journal(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {boolean}
     */
    coordinate_journal_enabled() {
        const ret = wasm.nativepeerbitbackbone_coordinate_journal_enabled(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {Uint8Array}
     */
    coordinate_journal_header() {
        const ret = wasm.nativepeerbitbackbone_coordinate_journal_header(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {number}
     */
    coordinate_pending_journal_byte_len() {
        const ret = wasm.nativepeerbitbackbone_coordinate_pending_journal_byte_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    coordinate_pending_journal_len() {
        const ret = wasm.nativepeerbitbackbone_coordinate_pending_journal_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {Uint8Array}
     */
    coordinate_snapshot() {
        const ret = wasm.nativepeerbitbackbone_coordinate_snapshot(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {number}
     */
    coordinate_value_len() {
        const ret = wasm.nativepeerbitbackbone_coordinate_value_len(this.__wbg_ptr);
        return ret >>> 0;
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
        const ret = wasm.nativepeerbitbackbone_count_entry_coordinates_in_ranges(this.__wbg_ptr, start1, end1, start2, end2, include_assigned_to_range_boundary);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {string} key
     * @returns {boolean}
     */
    delete_document(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_delete_document(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} keys
     * @returns {number}
     */
    delete_documents(keys) {
        const ret = wasm.nativepeerbitbackbone_delete_documents(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {Array<any>} keys
     * @returns {Uint8Array}
     */
    delete_documents_result(keys) {
        const ret = wasm.nativepeerbitbackbone_delete_documents_result(this.__wbg_ptr, keys);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    delete_entry_coordinates(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_delete_entry_coordinates(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} hashes
     */
    delete_entry_coordinates_batch(hashes) {
        const ret = wasm.nativepeerbitbackbone_delete_entry_coordinates_batch(this.__wbg_ptr, hashes);
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
        const ret = wasm.nativepeerbitbackbone_delete_gid_peers(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {string} id
     * @returns {boolean}
     */
    delete_range(id) {
        const ptr0 = passStringToWasm0(id, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_delete_range(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {string} key
     * @returns {any}
     */
    document_context(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_context(this.__wbg_ptr, ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string[]} keys
     * @returns {Array<any>}
     */
    document_context_batch(keys) {
        const ptr0 = passArrayJsValueToWasm0(keys, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_context_batch(this.__wbg_ptr, ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string[]} keys
     * @returns {Array<any>}
     */
    document_context_previous_signature_public_key_batch(keys) {
        const ptr0 = passArrayJsValueToWasm0(keys, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_context_previous_signature_public_key_batch(this.__wbg_ptr, ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Uint8Array} query_bytes
     * @returns {number}
     */
    document_count(query_bytes) {
        const ptr0 = passArray8ToWasm0(query_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_count(this.__wbg_ptr, ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {string} key
     * @returns {any}
     */
    document_entry(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_entry(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {number} field
     * @param {string} value
     * @returns {any}
     */
    document_exact_string_first_key(field, value) {
        const ptr0 = passStringToWasm0(value, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_exact_string_first_key(this.__wbg_ptr, field, ptr0, len0);
        return ret;
    }
    /**
     * @param {string} key
     * @param {number} field
     * @returns {any}
     */
    document_field_value(key, field) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_field_value(this.__wbg_ptr, ptr0, len0, field);
        return ret;
    }
    /**
     * @returns {number}
     */
    document_index_len() {
        const ret = wasm.nativepeerbitbackbone_document_index_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {Uint8Array}
     */
    document_journal() {
        const ret = wasm.nativepeerbitbackbone_document_journal(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {boolean}
     */
    document_journal_enabled() {
        const ret = wasm.nativepeerbitbackbone_document_journal_enabled(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {Uint8Array}
     */
    document_journal_header() {
        const ret = wasm.nativepeerbitbackbone_document_journal_header(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @param {string[]} keys
     * @returns {Uint8Array}
     */
    document_keys_exist(keys) {
        const ptr0 = passArrayJsValueToWasm0(keys, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_keys_exist(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @returns {number}
     */
    document_pending_journal_byte_len() {
        const ret = wasm.nativepeerbitbackbone_document_pending_journal_byte_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    document_pending_journal_len() {
        const ret = wasm.nativepeerbitbackbone_document_pending_journal_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {string} key
     * @returns {Array<any>}
     */
    document_previous_signature_public_key(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_previous_signature_public_key(this.__wbg_ptr, ptr0, len0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Uint8Array} query_bytes
     * @param {Uint8Array} sort_bytes
     * @returns {Array<any>}
     */
    document_query(query_bytes, sort_bytes) {
        const ptr0 = passArray8ToWasm0(query_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(sort_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_query(this.__wbg_ptr, ptr0, len0, ptr1, len1);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Uint8Array} query_bytes
     * @param {Uint8Array} sort_bytes
     * @param {number} offset
     * @param {number} limit
     * @returns {Array<any>}
     */
    document_query_page(query_bytes, sort_bytes, offset, limit) {
        const ptr0 = passArray8ToWasm0(query_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(sort_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_query_page(this.__wbg_ptr, ptr0, len0, ptr1, len1, offset, limit);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {Uint8Array}
     */
    document_signer_journal() {
        const ret = wasm.nativepeerbitbackbone_document_signer_journal(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {boolean}
     */
    document_signer_journal_enabled() {
        const ret = wasm.nativepeerbitbackbone_document_signer_journal_enabled(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {Uint8Array}
     */
    document_signer_journal_header() {
        const ret = wasm.nativepeerbitbackbone_document_signer_journal_header(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {number}
     */
    document_signer_pending_journal_byte_len() {
        const ret = wasm.nativepeerbitbackbone_document_signer_pending_journal_byte_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    document_signer_pending_journal_len() {
        const ret = wasm.nativepeerbitbackbone_document_signer_pending_journal_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {Uint8Array}
     */
    document_signer_snapshot() {
        const ret = wasm.nativepeerbitbackbone_document_signer_snapshot(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @returns {Uint8Array}
     */
    document_snapshot() {
        const ret = wasm.nativepeerbitbackbone_document_snapshot(this.__wbg_ptr);
        var v1 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        return v1;
    }
    /**
     * @param {Uint8Array} query_bytes
     * @param {number} field
     * @returns {Array<any>}
     */
    document_sum(query_bytes, field) {
        const ptr0 = passArray8ToWasm0(query_bytes, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_sum(this.__wbg_ptr, ptr0, len0, field);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} key
     * @returns {any}
     */
    document_value_bytes(key) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_document_value_bytes(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @returns {number}
     */
    document_value_len() {
        const ret = wasm.nativepeerbitbackbone_document_value_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Serialize one outbound raw exchange sync payload (the full PubSubData
     * nesting) from the native block store. Returns `undefined` when any
     * head's block is not natively stored (the caller falls back to the TS
     * serialization path).
     * @param {string} topic
     * @param {boolean} strict
     * @param {Array<any>} hashes
     * @param {Array<any>} gid_refrences
     * @param {Uint8Array} reserved
     * @returns {any}
     */
    encode_raw_exchange_sync_payload(topic, strict, hashes, gid_refrences, reserved) {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(reserved, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_encode_raw_exchange_sync_payload(this.__wbg_ptr, ptr0, len0, strict, hashes, gid_refrences, ptr1, len1);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {Array<any>}
     */
    entry_coordinate_fields() {
        const ret = wasm.nativepeerbitbackbone_entry_coordinate_fields(this.__wbg_ptr);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {Array<any>}
     */
    entry_coordinate_hashes() {
        const ret = wasm.nativepeerbitbackbone_entry_coordinate_hashes(this.__wbg_ptr);
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
        const ret = wasm.nativepeerbitbackbone_entry_hash_numbers_in_range(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
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
        const ret = wasm.nativepeerbitbackbone_entry_hash_numbers_in_range_u64(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
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
        const ret = wasm.nativepeerbitbackbone_entry_hashes_for_hash_numbers(this.__wbg_ptr, hash_numbers);
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
        const ret = wasm.nativepeerbitbackbone_entry_hashes_for_hash_numbers_flat_u64(this.__wbg_ptr, hash_numbers);
        return ret;
    }
    /**
     * @param {BigUint64Array} hash_numbers
     * @returns {Array<any>}
     */
    entry_hashes_for_hash_numbers_u64(hash_numbers) {
        const ret = wasm.nativepeerbitbackbone_entry_hashes_for_hash_numbers_u64(this.__wbg_ptr, hash_numbers);
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
        const ret = wasm.nativepeerbitbackbone_find_leaders(this.__wbg_ptr, cursors, replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_find_leaders_batch(this.__wbg_ptr, cursor_batches, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_get_entry_coordinates(this.__wbg_ptr, ptr0, len0);
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
        const ret = wasm.nativepeerbitbackbone_get_gid_coordinates(this.__wbg_ptr, ptr0, len0, count);
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
        const ret = wasm.nativepeerbitbackbone_get_grid(this.__wbg_ptr, ptr0, len0, count);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @returns {Array<any>}
     */
    graph_child_join_entries(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_child_join_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    graph_clear() {
        wasm.nativepeerbitbackbone_graph_clear(this.__wbg_ptr);
    }
    /**
     * @param {string} next
     * @param {string | null} [exclude_hash]
     * @returns {number}
     */
    graph_count_has_next(next, exclude_hash) {
        const ptr0 = passStringToWasm0(next, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(exclude_hash) ? 0 : passStringToWasm0(exclude_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_count_has_next(this.__wbg_ptr, ptr0, len0, ptr1, len1);
        return ret >>> 0;
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    graph_delete(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_delete(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @returns {number}
     */
    graph_delete_many(hashes) {
        const ret = wasm.nativepeerbitbackbone_graph_delete_many(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    graph_entry_metadata_batch(hashes) {
        const ret = wasm.nativepeerbitbackbone_graph_entry_metadata_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    graph_entry_metadata_hints_batch(hashes) {
        const ret = wasm.nativepeerbitbackbone_graph_entry_metadata_hints_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    graph_entry_signature_public_key_batch(hashes) {
        const ret = wasm.nativepeerbitbackbone_graph_entry_signature_public_key_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} gids
     * @returns {boolean}
     */
    graph_has_any_head(gids) {
        const ret = wasm.nativepeerbitbackbone_graph_has_any_head(this.__wbg_ptr, gids);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} gid_sets
     * @returns {Array<any>}
     */
    graph_has_any_head_batch(gid_sets) {
        const ret = wasm.nativepeerbitbackbone_graph_has_any_head_batch(this.__wbg_ptr, gid_sets);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string | null} [gid]
     * @returns {boolean}
     */
    graph_has_head(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_has_head(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    graph_has_many(hashes) {
        const ret = wasm.nativepeerbitbackbone_graph_has_many(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    graph_head_data_entries(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_head_data_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    graph_head_entries(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_head_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    graph_heads(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_heads(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string | null} [gid]
     * @returns {Array<any>}
     */
    graph_join_head_entries(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_join_head_entries(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string | null} [gid]
     * @returns {any}
     */
    graph_max_head_data_u32(gid) {
        var ptr0 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_max_head_data_u32(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {Array<any>} gids
     * @returns {Array<any>}
     */
    graph_max_head_data_u32_batch(gids) {
        const ret = wasm.nativepeerbitbackbone_graph_max_head_data_u32_batch(this.__wbg_ptr, gids);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @returns {any}
     */
    graph_newest_hash() {
        const ret = wasm.nativepeerbitbackbone_graph_newest_hash(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {number} limit
     * @returns {Array<any>}
     */
    graph_oldest_entries(limit) {
        const ret = wasm.nativepeerbitbackbone_graph_oldest_entries(this.__wbg_ptr, limit);
        return ret;
    }
    /**
     * @returns {any}
     */
    graph_oldest_hash() {
        const ret = wasm.nativepeerbitbackbone_graph_oldest_hash(this.__wbg_ptr);
        return ret;
    }
    /**
     * @returns {number}
     */
    graph_payload_size_sum() {
        const ret = wasm.nativepeerbitbackbone_graph_payload_size_sum(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {Array<any>} hashes
     * @param {boolean} skip_first
     * @returns {Array<any>}
     */
    graph_plan_delete_recursively(hashes, skip_first) {
        const ret = wasm.nativepeerbitbackbone_graph_plan_delete_recursively(this.__wbg_ptr, hashes, skip_first);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {boolean} reset
     * @param {string | null} [gid]
     * @param {bigint | null} [wall_time]
     * @param {number | null} [logical]
     * @returns {Array<any>}
     */
    graph_plan_join(hash, next, entry_type, reset, gid, wall_time, logical) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(gid) ? 0 : passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_plan_join(this.__wbg_ptr, ptr0, len0, next, entry_type, reset, ptr1, len1, !isLikeNone(wall_time), isLikeNone(wall_time) ? BigInt(0) : wall_time, isLikeNone(logical) ? Number.MAX_SAFE_INTEGER : (logical) >>> 0);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} nexts
     * @param {Uint8Array} entry_types
     * @param {boolean} reset
     * @param {Array<any>} gids
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {boolean} cut_check
     * @returns {Array<any>}
     */
    graph_plan_join_batch(hashes, nexts, entry_types, reset, gids, wall_times, logicals, cut_check) {
        const ret = wasm.nativepeerbitbackbone_graph_plan_join_batch(this.__wbg_ptr, hashes, nexts, entry_types, reset, gids, wall_times, logicals, cut_check);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {number} payload_size
     * @param {boolean} head
     * @param {any} data
     */
    graph_put(hash, gid, next, entry_type, wall_time, logical, payload_size, head, data) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_put(this.__wbg_ptr, ptr0, len0, ptr1, len1, next, entry_type, wall_time, logical, payload_size, head, data);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} gid
     * @param {Array<any>} initial_next
     * @param {number} entry_type
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Uint32Array} payload_sizes
     * @param {Array<any>} datas
     */
    graph_put_append_chain(hashes, gid, initial_next, entry_type, wall_times, logicals, payload_sizes, datas) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_put_append_chain(this.__wbg_ptr, hashes, ptr0, len0, initial_next, entry_type, wall_times, logicals, payload_sizes, datas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} gids
     * @param {Array<any>} nexts
     * @param {Uint8Array} entry_types
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Uint32Array} payload_sizes
     * @param {Uint8Array} heads
     * @param {Array<any>} datas
     */
    graph_put_batch(hashes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas) {
        const ret = wasm.nativepeerbitbackbone_graph_put_batch(this.__wbg_ptr, hashes, gids, nexts, entry_types, wall_times, logicals, payload_sizes, heads, datas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} gid
     * @param {Array<any>} next
     * @param {string | null} [exclude_hash]
     * @returns {Array<any>}
     */
    graph_shadowed_gids(gid, next, exclude_hash) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        var ptr1 = isLikeNone(exclude_hash) ? 0 : passStringToWasm0(exclude_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        var len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_shadowed_gids(this.__wbg_ptr, ptr0, len0, next, ptr1, len1);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    graph_unique_reference_gid_rows_batch(hashes) {
        const ret = wasm.nativepeerbitbackbone_graph_unique_reference_gid_rows_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {any}
     */
    graph_unique_reference_gid_rows_flat_batch(hashes) {
        const ret = wasm.nativepeerbitbackbone_graph_unique_reference_gid_rows_flat_batch(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} hash
     * @returns {any}
     */
    graph_unique_reference_gids(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_graph_unique_reference_gids(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    has_block(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_has_block(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {string} hash
     * @returns {boolean}
     */
    has_log_entry(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_has_log_entry(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @param {Uint8Array} snapshot
     * @param {Uint8Array} journal
     * @returns {number}
     */
    load_coordinate_snapshot_and_journal(snapshot, journal) {
        const ret = wasm.nativepeerbitbackbone_load_coordinate_snapshot_and_journal(this.__wbg_ptr, snapshot, journal);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {Uint8Array} snapshot
     * @param {Uint8Array} journal
     * @returns {number}
     */
    load_document_signer_snapshot_and_journal(snapshot, journal) {
        const ret = wasm.nativepeerbitbackbone_load_document_signer_snapshot_and_journal(this.__wbg_ptr, snapshot, journal);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {Uint8Array} snapshot
     * @param {Uint8Array} journal
     * @returns {number}
     */
    load_document_snapshot_and_journal(snapshot, journal) {
        const ret = wasm.nativepeerbitbackbone_load_document_snapshot_and_journal(this.__wbg_ptr, snapshot, journal);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @returns {number}
     */
    log_len() {
        const ret = wasm.nativepeerbitbackbone_log_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} peer
     */
    mark_entries_known_by_peer(hashes, peer) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_mark_entries_known_by_peer(this.__wbg_ptr, hashes, ptr0, len0);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {string} resolution
     * @param {Uint8Array} clock_id
     * @param {Uint8Array} private_key
     * @param {Uint8Array} public_key
     */
    constructor(resolution, clock_id, private_key, public_key) {
        const ptr0 = passStringToWasm0(resolution, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_new(ptr0, len0, clock_id, private_key, public_key);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        this.__wbg_ptr = ret[0];
        NativePeerbitBackboneFinalization.register(this, this.__wbg_ptr, this);
        return this;
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
        const ret = wasm.nativepeerbitbackbone_plan_append_for_gid(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, next_hashes, replicas, full_replica_candidates, fallback_recipients, ptr3, len3, delivery_enabled, reliability_ack, min_acks, require_recipients, role_age_ms, ptr4, len4, peer_filter, expand_peer_filter, ptr5, len5, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_append_for_gids_batch(this.__wbg_ptr, entry_hashes, gids, entry_hash_numbers, next_hash_batches, replica_counts, full_replica_candidates, fallback_recipients, ptr0, len0, delivery_enabled, reliability_ack, min_acks, require_recipients, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_entry_assignment_for_gid(this.__wbg_ptr, ptr0, len0, replicas, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_entry_leaders_for_gid(this.__wbg_ptr, ptr0, len0, replicas, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_leader_samples_for_gids_batch(this.__wbg_ptr, gids, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_leaders_for_gids_batch(this.__wbg_ptr, gids, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_local_append_for_gid_compact(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, next_hashes, replicas, role_age_ms, ptr3, len3, peer_filter, expand_peer_filter, ptr4, len4, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @param {string} _from_hash
     * @returns {any}
     */
    plan_prepared_raw_receive_fast_drop(hashes, min_replicas, max_replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica, _from_hash) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(_from_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_prepared_raw_receive_fast_drop(this.__wbg_ptr, hashes, min_replicas, max_replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica, ptr2, len2);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @param {string} from_hash
     * @returns {any}
     */
    plan_prepared_raw_receive_group_assignments(hashes, min_replicas, max_replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica, from_hash) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(from_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_prepared_raw_receive_group_assignments(this.__wbg_ptr, hashes, min_replicas, max_replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica, ptr2, len2);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @returns {any}
     */
    plan_prepared_raw_receive_group_indexes(hashes, min_replicas, max_replicas) {
        const ret = wasm.nativepeerbitbackbone_plan_prepared_raw_receive_group_indexes(this.__wbg_ptr, hashes, min_replicas, max_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {any}
     */
    plan_prepared_raw_receive_group_leaders(hashes, min_replicas, max_replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_prepared_raw_receive_group_leaders(this.__wbg_ptr, hashes, min_replicas, max_replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @returns {any}
     */
    plan_prepared_raw_receive_groups(hashes, min_replicas, max_replicas) {
        const ret = wasm.nativepeerbitbackbone_plan_prepared_raw_receive_groups(this.__wbg_ptr, hashes, min_replicas, max_replicas);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @param {string} _from_hash
     * @returns {any}
     */
    plan_prepared_raw_receive_selection(hashes, min_replicas, max_replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica, _from_hash) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(_from_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_prepared_raw_receive_selection(this.__wbg_ptr, hashes, min_replicas, max_replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica, ptr2, len2);
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
        const ret = wasm.nativepeerbitbackbone_plan_receive_coordinates_for_gids_batch(this.__wbg_ptr, entry_hashes, gids, entry_hash_numbers, next_hash_batches, replica_counts, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_repair_dispatch_for_entries(this.__wbg_ptr, entry_hashes, entry_gids, entry_requested_replicas, entry_coordinate_batches, pending_modes, pending_peers_by_mode, optimistic_peers_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
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
        const ret = wasm.nativepeerbitbackbone_plan_repair_dispatch_for_resident_entries(this.__wbg_ptr, pending_modes, pending_peers_by_mode, optimistic_gids_by_mode, optimistic_peers_by_gid_by_mode, full_replica_repair_candidates, full_replica_repair_candidate_count, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} prune_peer
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
    plan_request_prune_all_confirmed(hashes, prune_peer, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(prune_peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_request_prune_all_confirmed(this.__wbg_ptr, hashes, ptr0, len0, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} prune_peer
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @returns {boolean}
     */
    plan_request_prune_all_confirmed_no_gid_return(hashes, prune_peer, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(prune_peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_request_prune_all_confirmed_no_gid_return(this.__wbg_ptr, hashes, ptr0, len0, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] !== 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} skip_hashes
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
    plan_request_prune_leader_hint_columns(hashes, skip_hashes, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_request_prune_leader_hint_columns(this.__wbg_ptr, hashes, skip_hashes, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @param {Array<any>} skip_hashes
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
    plan_request_prune_leader_hints(hashes, skip_hashes, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_plan_request_prune_leader_hints(this.__wbg_ptr, hashes, skip_hashes, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint32Array} document_projection_plan_ids
     * @param {Array<any>} document_projection_encoded_documents
     * @param {Array<any>} document_projection_signers
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_batch_transaction(wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_batch_transaction(this.__wbg_ptr, wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint32Array} document_projection_plan_ids
     * @param {Array<any>} document_projection_signers
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_batch_transaction(wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_signers, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_batch_transaction(this.__wbg_ptr, wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_signers, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_signer
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction_trim(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_value_prefix_bytes
     * @param {Array<any>} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_compact_batch_transaction(wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_batch_transaction(this.__wbg_ptr, wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_batch_transaction(wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_batch_transaction(this.__wbg_ptr, wall_times, logicals, gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_compact_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_document_index_transaction_trim(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_no_next_storage_append_transaction_trim(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_delete_transaction(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_delete_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_delete_transaction_trim(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_delete_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, resolve_trimmed_entries, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {Array<any>} document_keys
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint32Array} document_projection_plan_ids
     * @param {Array<any>} document_projection_encoded_documents
     * @param {Array<any>} document_projection_signers
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, resolve_trimmed_entries, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint32Array} document_projection_plan_ids
     * @param {Array<any>} document_projection_encoded_documents
     * @param {Array<any>} document_projection_signers
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint32Array} document_projection_plan_ids
     * @param {Array<any>} document_projection_signers
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_signers, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_signers, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_signer
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_compact_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_compact_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint8Array} required_previous_signer_public_key
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, required_previous_signer_public_key, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, resolve_trimmed_entries, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, required_previous_signer_public_key, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {Array<any>} document_keys
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint32Array} document_projection_plan_ids
     * @param {Array<any>} document_projection_encoded_documents
     * @param {Array<any>} document_projection_signers
     * @param {Uint8Array} required_previous_signer_public_key
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, required_previous_signer_public_key, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, resolve_trimmed_entries, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, required_previous_signer_public_key, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint32Array} document_projection_plan_ids
     * @param {Array<any>} document_projection_encoded_documents
     * @param {Array<any>} document_projection_signers
     * @param {Uint8Array} required_previous_signer_public_key
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_compact_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, required_previous_signer_public_key, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_compact_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_ids, document_projection_encoded_documents, document_projection_signers, required_previous_signer_public_key, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {BigUint64Array} wall_times
     * @param {Uint32Array} logicals
     * @param {Array<any>} fallback_gids
     * @param {number} entry_type
     * @param {Array<any>} meta_datas
     * @param {Array<any>} payload_datas
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {Array<any>} document_keys
     * @param {Array<any>} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {Uint8Array} required_previous_signer_public_key
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_batch_transaction(wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, now, self_hash, self_replicating, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, required_previous_signer_public_key, trim_length_to) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_batch_transaction(this.__wbg_ptr, wall_times, logicals, fallback_gids, entry_type, meta_datas, payload_datas, replicas, role_age_ms, ptr0, len0, ptr1, len1, self_replicating, document_keys, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, required_previous_signer_public_key, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {Uint8Array} required_previous_signer_public_key
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, document_key, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, required_previous_signer_public_key, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, required_previous_signer_public_key, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {Uint8Array} required_previous_signer_public_key
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, required_previous_signer_public_key, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, required_previous_signer_public_key, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_latest_transaction(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_transaction(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_document_index_transaction_trim(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_transaction(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_committed_storage_append_transaction_trim(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_committed_storage_append_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {any} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_facts(wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_facts(this.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {any} trim_length_to
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_facts_document_index(wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_facts_document_index(this.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {any} trim_length_to
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_facts_document_index_cached_plan(wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_facts_document_index_cached_plan(this.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {any} trim_length_to
     * @param {string} document_key
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_latest_facts_document_index_cached_plan_trim_hashes(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, trim_length_to, document_key, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_latest_facts_document_index_cached_plan_trim_hashes(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} fallback_gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {any} trim_length_to
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_latest_facts_document_index_trim_hashes(wall_time, logical, fallback_gid, entry_type, meta_data, payload_data, trim_length_to, document_key, document_value_prefix_bytes, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(fallback_gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_latest_facts_document_index_trim_hashes(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact(wall_time, logical, gid, entry_type, meta_data, payload_data, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, ptr1, len1, ptr2, len2, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_plain_put_payload(wall_time, logical, gid, entry_type, meta_data, payload_data, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_plain_put_payload(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, ptr1, len1, ptr2, len2, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes(wall_time, logical, gid, entry_type, meta_data, payload_data, trim_length_to, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes_plain_put_payload(wall_time, logical, gid, entry_type, meta_data, payload_data, trim_length_to, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes_plain_put_payload(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @param {string} document_key
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {number} document_projection_plan_id
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_trim_hashes(wall_time, logical, gid, entry_type, meta_data, payload_data, trim_length_to, document_key, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_trim_hashes(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan_id, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_compact(wall_time, logical, gid, entry_type, meta_data, payload_data, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_compact(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, ptr1, len1, ptr2, len2, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_compact_trim_hashes(wall_time, logical, gid, entry_type, meta_data, payload_data, trim_length_to, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_compact_trim_hashes(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_entry_commit_no_next_facts_document_index_trim_hashes(wall_time, logical, gid, entry_type, meta_data, payload_data, trim_length_to, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_trim_hashes(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, trim_length_to, ptr1, len1, ptr2, len2, ptr3, len3, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @returns {Array<any>}
     */
    prepare_plain_entry_storage_facts_and_put(wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_storage_facts_and_put(this.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_entry_storage_facts_trim_and_put(wall_time, logical, gid, next, entry_type, meta_data, payload_data, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_entry_storage_facts_trim_and_put(this.__wbg_ptr, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_no_next_storage_append_document_index_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_no_next_storage_append_document_index_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_no_next_storage_append_document_index_transaction_trim(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_no_next_storage_append_document_index_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @returns {Array<any>}
     */
    prepare_plain_no_next_storage_append_transaction(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_no_next_storage_append_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_no_next_storage_append_transaction_trim(wall_time, logical, gid, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_no_next_storage_append_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @returns {Array<any>}
     */
    prepare_plain_storage_append_document_index_transaction(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_storage_append_document_index_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {string} document_key
     * @param {Uint8Array} document_value_prefix_bytes
     * @param {string} document_existing_created
     * @param {number} document_byte_element_index_limit
     * @param {boolean} document_delete_trimmed_heads
     * @param {any} document_projection_plan
     * @param {any} document_projection_encoded_document
     * @param {any} document_projection_signer
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_storage_append_document_index_transaction_trim(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, document_key, document_value_prefix_bytes, document_existing_created, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(document_key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ptr4 = passArray8ToWasm0(document_value_prefix_bytes, wasm.__wbindgen_malloc);
        const len4 = WASM_VECTOR_LEN;
        const ptr5 = passStringToWasm0(document_existing_created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len5 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_storage_append_document_index_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, ptr3, len3, ptr4, len4, ptr5, len5, document_byte_element_index_limit, document_delete_trimmed_heads, document_projection_plan, document_projection_encoded_document, document_projection_signer, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @returns {Array<any>}
     */
    prepare_plain_storage_append_transaction(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_storage_append_transaction(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {bigint} wall_time
     * @param {number} logical
     * @param {string} gid
     * @param {Array<any>} next_hashes
     * @param {number} entry_type
     * @param {any} meta_data
     * @param {Uint8Array} payload_data
     * @param {number} replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {string} self_hash
     * @param {boolean} self_replicating
     * @param {boolean} resolve_trimmed_entries
     * @param {number} trim_length_to
     * @returns {Array<any>}
     */
    prepare_plain_storage_append_transaction_trim(wall_time, logical, gid, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, now, self_hash, self_replicating, resolve_trimmed_entries, trim_length_to) {
        const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_plain_storage_append_transaction_trim(this.__wbg_ptr, wall_time, logical, ptr0, len0, next_hashes, entry_type, meta_data, payload_data, replicas, role_age_ms, ptr1, len1, ptr2, len2, self_replicating, resolve_trimmed_entries, trim_length_to);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @returns {Array<any>}
     */
    prepare_raw_receive_batch(blocks) {
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_batch(this.__wbg_ptr, blocks);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @returns {Array<any>}
     */
    prepare_raw_receive_columns_batch(blocks) {
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_columns_batch(this.__wbg_ptr, blocks);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    prepare_raw_receive_expected_columns_batch(blocks, hashes) {
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_expected_columns_batch(this.__wbg_ptr, blocks, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    prepare_raw_receive_expected_compact_columns_batch(blocks, hashes) {
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_expected_compact_columns_batch(this.__wbg_ptr, blocks, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @returns {Array<any>}
     */
    prepare_raw_receive_unverified_columns_batch(blocks) {
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_unverified_columns_batch(this.__wbg_ptr, blocks);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    prepare_raw_receive_unverified_expected_columns_batch(blocks, hashes) {
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_unverified_expected_columns_batch(this.__wbg_ptr, blocks, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @param {string} _from_hash
     * @returns {any}
     */
    prepare_raw_receive_unverified_expected_compact_columns_and_selection_batch(blocks, hashes, min_replicas, max_replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica, _from_hash) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(_from_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_unverified_expected_compact_columns_and_selection_batch(this.__wbg_ptr, blocks, hashes, min_replicas, max_replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica, ptr2, len2);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} blocks
     * @param {Array<any>} hashes
     * @returns {Array<any>}
     */
    prepare_raw_receive_unverified_expected_compact_columns_batch(blocks, hashes) {
        const ret = wasm.nativepeerbitbackbone_prepare_raw_receive_unverified_expected_compact_columns_batch(this.__wbg_ptr, blocks, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * Stashed-input twin of
     * `prepare_raw_receive_unverified_expected_compact_columns_and_selection_batch`.
     * @param {NativeWireSyncSession} session
     * @param {Uint8Array} id
     * @param {Uint32Array} indexes
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @param {string} _from_hash
     * @returns {any}
     */
    prepare_stashed_raw_receive_expected_compact_columns_and_selection_batch(session, id, indexes, hashes, min_replicas, max_replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica, _from_hash) {
        _assertClass(session, NativeWireSyncSession);
        const ptr0 = passArray8ToWasm0(id, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(_from_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_stashed_raw_receive_expected_compact_columns_and_selection_batch(this.__wbg_ptr, session.__wbg_ptr, ptr0, len0, indexes, hashes, min_replicas, max_replicas, role_age_ms, ptr1, len1, peer_filter, expand_peer_filter, ptr2, len2, include_self, full_replica_fallback, include_strict_full_replica, ptr3, len3);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * Stashed-input twin of
     * `prepare_raw_receive_unverified_expected_compact_columns_batch`: the
     * blocks come from the wire stash (wasm memory) instead of a JS array.
     * @param {NativeWireSyncSession} session
     * @param {Uint8Array} id
     * @param {Uint32Array} indexes
     * @param {Array<any>} hashes
     * @param {boolean} verify_signatures
     * @returns {any}
     */
    prepare_stashed_raw_receive_expected_compact_columns_batch(session, id, indexes, hashes, verify_signatures) {
        _assertClass(session, NativeWireSyncSession);
        const ptr0 = passArray8ToWasm0(id, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_prepare_stashed_raw_receive_expected_compact_columns_batch(this.__wbg_ptr, session.__wbg_ptr, ptr0, len0, indexes, hashes, verify_signatures);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Uint8Array} encoded_document
     * @param {any} plan
     * @param {string} created
     * @param {string} modified
     * @param {string} head
     * @param {string} gid
     * @param {number} size
     * @param {any} signer
     * @returns {Uint8Array}
     */
    project_document_index_simple(encoded_document, plan, created, modified, head, gid, size, signer) {
        const ptr0 = passStringToWasm0(created, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(modified, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(head, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ptr3 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len3 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_project_document_index_simple(this.__wbg_ptr, encoded_document, plan, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, size, signer);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {string} key
     * @param {Uint8Array} value_prefix_bytes
     * @param {Uint8Array} value_suffix_bytes
     * @param {number} byte_element_index_limit
     */
    put_document_encoded_parts_stored(key, value_prefix_bytes, value_suffix_bytes, byte_element_index_limit) {
        const ptr0 = passStringToWasm0(key, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passArray8ToWasm0(value_prefix_bytes, wasm.__wbindgen_malloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passArray8ToWasm0(value_suffix_bytes, wasm.__wbindgen_malloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_put_document_encoded_parts_stored(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, byte_element_index_limit);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {Array<any>} keys
     * @param {Array<any>} value_prefix_bytes
     * @param {Array<any>} value_suffix_bytes
     * @param {number} byte_element_index_limit
     */
    put_document_encoded_parts_stored_batch(keys, value_prefix_bytes, value_suffix_bytes, byte_element_index_limit) {
        const ret = wasm.nativepeerbitbackbone_put_document_encoded_parts_stored_batch(this.__wbg_ptr, keys, value_prefix_bytes, value_suffix_bytes, byte_element_index_limit);
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
        const ret = wasm.nativepeerbitbackbone_put_entry_coordinates(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, coordinates, assigned_to_range_boundary, requested_replicas);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
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
    put_range(id, hash, timestamp, start1, end1, start2, end2, width, mode) {
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
        const ret = wasm.nativepeerbitbackbone_put_range(this.__wbg_ptr, ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, ptr6, len6, ptr7, len7, mode);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * Sync fallback for lazily materialized stash-backed heads whose stash
     * entry was already released: serve the raw block bytes from the pending
     * prepared entries or the committed block store.
     * @param {string} hash
     * @returns {any}
     */
    raw_receive_block_bytes(hash) {
        const ptr0 = passStringToWasm0(hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_raw_receive_block_bytes(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @param {any} plan
     * @returns {number}
     */
    register_document_projection_plan(plan) {
        const ret = wasm.nativepeerbitbackbone_register_document_projection_plan(this.__wbg_ptr, plan);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return ret[0] >>> 0;
    }
    /**
     * @param {Array<any>} hashes
     * @param {string} peer
     */
    remove_entries_known_by_peer(hashes, peer) {
        const ptr0 = passStringToWasm0(peer, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_remove_entries_known_by_peer(this.__wbg_ptr, hashes, ptr0, len0);
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
        const ret = wasm.nativepeerbitbackbone_remove_gid_peer(this.__wbg_ptr, ptr0, len0, gid);
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
        const ret = wasm.nativepeerbitbackbone_remove_gid_peers(this.__wbg_ptr, ptr0, len0, gids);
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
        wasm.nativepeerbitbackbone_remove_peer_from_entry_known_peers(this.__wbg_ptr, ptr0, len0);
    }
    reset_append_profile() {
        wasm.nativepeerbitbackbone_reset_append_profile(this.__wbg_ptr);
    }
    /**
     * @param {Array<any>} hashes
     * @param {number} min_replicas
     * @param {any} max_replicas
     * @param {number} role_age_ms
     * @param {string} now
     * @param {any} peer_filter
     * @param {boolean} expand_peer_filter
     * @param {string} self_hash
     * @param {boolean} include_self
     * @param {boolean} full_replica_fallback
     * @param {boolean} include_strict_full_replica
     * @param {string} _from_hash
     * @returns {any}
     */
    select_prepared_raw_receive_hashes(hashes, min_replicas, max_replicas, role_age_ms, now, peer_filter, expand_peer_filter, self_hash, include_self, full_replica_fallback, include_strict_full_replica, _from_hash) {
        const ptr0 = passStringToWasm0(now, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ptr2 = passStringToWasm0(_from_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len2 = WASM_VECTOR_LEN;
        const ret = wasm.nativepeerbitbackbone_select_prepared_raw_receive_hashes(this.__wbg_ptr, hashes, min_replicas, max_replicas, role_age_ms, ptr0, len0, peer_filter, expand_peer_filter, ptr1, len1, include_self, full_replica_fallback, include_strict_full_replica, ptr2, len2);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {boolean} enabled
     */
    set_append_profile_enabled(enabled) {
        wasm.nativepeerbitbackbone_set_append_profile_enabled(this.__wbg_ptr, enabled);
    }
    /**
     * @param {boolean} enabled
     */
    set_coordinate_journal_enabled(enabled) {
        wasm.nativepeerbitbackbone_set_coordinate_journal_enabled(this.__wbg_ptr, enabled);
    }
    /**
     * @param {number} limit
     */
    set_document_byte_element_index_limit(limit) {
        const ret = wasm.nativepeerbitbackbone_set_document_byte_element_index_limit(this.__wbg_ptr, limit);
        if (ret[1]) {
            throw takeFromExternrefTable0(ret[0]);
        }
    }
    /**
     * @param {number} created
     * @param {number} modified
     * @param {number} head
     * @param {number} gid
     * @param {number} size
     */
    set_document_context_fields(created, modified, head, gid, size) {
        wasm.nativepeerbitbackbone_set_document_context_fields(this.__wbg_ptr, created, modified, head, gid, size);
    }
    /**
     * @param {number} field
     */
    set_document_context_head_field(field) {
        wasm.nativepeerbitbackbone_set_document_context_head_field(this.__wbg_ptr, field);
    }
    /**
     * @param {boolean} enabled
     */
    set_document_journal_enabled(enabled) {
        wasm.nativepeerbitbackbone_set_document_journal_enabled(this.__wbg_ptr, enabled);
    }
    /**
     * @param {boolean} enabled
     */
    set_document_signer_journal_enabled(enabled) {
        wasm.nativepeerbitbackbone_set_document_signer_journal_enabled(this.__wbg_ptr, enabled);
    }
    /**
     * Byte lengths of natively stored entry blocks for `hashes`;
     * `u32::MAX` marks a missing block. Used by the fused send path to plan
     * message chunking without materializing block bytes in JS.
     * @param {Array<any>} hashes
     * @returns {Uint32Array}
     */
    sync_send_block_byte_lengths(hashes) {
        const ret = wasm.nativepeerbitbackbone_sync_send_block_byte_lengths(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
    /**
     * @param {Array<any>} hashes
     * @returns {any}
     */
    verify_prepared_raw_receive_entries(hashes) {
        const ret = wasm.nativepeerbitbackbone_verify_prepared_raw_receive_entries(this.__wbg_ptr, hashes);
        if (ret[2]) {
            throw takeFromExternrefTable0(ret[1]);
        }
        return takeFromExternrefTable0(ret[0]);
    }
}
if (Symbol.dispose) NativePeerbitBackbone.prototype[Symbol.dispose] = NativePeerbitBackbone.prototype.free;

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

/**
 * Per-node receive-fusion state: the fused wire decoder for DirectStream and
 * the stash consumed by shared-log programs. See the module docs.
 */
export class NativeWireSyncSession {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        NativeWireSyncSessionFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_nativewiresyncsession_free(ptr, 0);
    }
    /**
     * `[stashed, evicted, metaReads, blockCopyOuts, released]`.
     * @returns {Uint32Array}
     */
    counters() {
        const ret = wasm.nativewiresyncsession_counters(this.__wbg_ptr);
        var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * Drop-in replacement for `peerbit_wire`'s `decode_and_verify_batch`
     * (same flat u32 record layout) that additionally stashes raw exchange
     * sync payloads for registered topics, flagging their records with
     * `RECORD_FLAG_SYNC_STASHED`.
     * @param {Array<any>} frames
     * @param {number} now_ms
     * @returns {Uint32Array}
     */
    decode_and_verify_batch(frames, now_ms) {
        const ret = wasm.nativewiresyncsession_decode_and_verify_batch(this.__wbg_ptr, frames, now_ms);
        var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @param {string} self_hash
     */
    constructor(self_hash) {
        const ptr0 = passStringToWasm0(self_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativewiresyncsession_new(ptr0, len0);
        this.__wbg_ptr = ret;
        NativeWireSyncSessionFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {string} topic
     */
    register_topic(topic) {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.nativewiresyncsession_register_topic(this.__wbg_ptr, ptr0, len0);
    }
    /**
     * @param {Uint8Array} id
     * @returns {boolean}
     */
    release(id) {
        const ptr0 = passArray8ToWasm0(id, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativewiresyncsession_release(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
    /**
     * @returns {number}
     */
    stash_len() {
        const ret = wasm.nativewiresyncsession_stash_len(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Copy head block bytes out to JS (fallback paths only — the fused path
     * hands blocks to `prepare_stashed_raw_receive_*` inside wasm memory).
     * @param {Uint8Array} id
     * @param {Uint32Array | null} [indexes]
     * @returns {any}
     */
    stashed_blocks(id, indexes) {
        const ptr0 = passArray8ToWasm0(id, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativewiresyncsession_stashed_blocks(this.__wbg_ptr, ptr0, len0, isLikeNone(indexes) ? 0 : addToExternrefTable0(indexes));
        return ret;
    }
    /**
     * Stash facts for a message id: `[hashes, gidRefrences, byteLengths,
     * reserved, payloadLength]`, or `undefined` when not stashed. Does not
     * consume the entry, but pins it: a resolved message has no TS decode
     * fallback anymore, so the entry must survive FIFO eviction until
     * `release` is called when processing finishes.
     * @param {Uint8Array} id
     * @returns {any}
     */
    stashed_meta(id) {
        const ptr0 = passArray8ToWasm0(id, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativewiresyncsession_stashed_meta(this.__wbg_ptr, ptr0, len0);
        return ret;
    }
    /**
     * @returns {number}
     */
    topic_count() {
        const ret = wasm.nativewiresyncsession_topic_count(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {string} topic
     * @returns {boolean}
     */
    unregister_topic(topic) {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.nativewiresyncsession_unregister_topic(this.__wbg_ptr, ptr0, len0);
        return ret !== 0;
    }
}
if (Symbol.dispose) NativeWireSyncSession.prototype[Symbol.dispose] = NativeWireSyncSession.prototype.free;

/**
 * A decoded `/peerbit/topic-control-plane` message. `Data` payload bytes are
 * reported as a range into the input frame so the host can alias them
 * without copying. `topics` doubles as the candidate list for the
 * `TopicRootCandidates` variant; `text` carries the public-key hash
 * (`PeerUnavailable`) or the topic (`TopicRootQuery`/`Response`).
 */
export class TopicControlDecodedMessage {
    static __wrap(ptr) {
        const obj = Object.create(TopicControlDecodedMessage.prototype);
        obj.__wbg_ptr = ptr;
        TopicControlDecodedMessageFinalization.register(obj, obj.__wbg_ptr, obj);
        return obj;
    }
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        TopicControlDecodedMessageFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_topiccontroldecodedmessage_free(ptr, 0);
    }
    /**
     * @returns {number}
     */
    get data_length() {
        const ret = wasm.topiccontroldecodedmessage_data_length(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get data_offset() {
        const ret = wasm.topiccontroldecodedmessage_data_offset(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * `strict` (PubSubData) or `requestSubscribers` (Subscribe).
     * @returns {boolean}
     */
    get flag() {
        const ret = wasm.topiccontroldecodedmessage_flag(this.__wbg_ptr);
        return ret !== 0;
    }
    /**
     * @returns {number}
     */
    get request_id() {
        const ret = wasm.topiccontroldecodedmessage_request_id(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {string | undefined}
     */
    get root() {
        const ret = wasm.topiccontroldecodedmessage_root(this.__wbg_ptr);
        let v1;
        if (ret[0] !== 0) {
            v1 = getStringFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v1;
    }
    /**
     * @returns {bigint}
     */
    get session() {
        const ret = wasm.topiccontroldecodedmessage_session(this.__wbg_ptr);
        return BigInt.asUintN(64, ret);
    }
    /**
     * @returns {string}
     */
    get text() {
        let deferred1_0;
        let deferred1_1;
        try {
            const ret = wasm.topiccontroldecodedmessage_text(this.__wbg_ptr);
            deferred1_0 = ret[0];
            deferred1_1 = ret[1];
            return getStringFromWasm0(ret[0], ret[1]);
        } finally {
            wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
        }
    }
    /**
     * @returns {bigint}
     */
    get timestamp() {
        const ret = wasm.topiccontroldecodedmessage_timestamp(this.__wbg_ptr);
        return BigInt.asUintN(64, ret);
    }
    /**
     * @returns {string[]}
     */
    get topics() {
        const ret = wasm.topiccontroldecodedmessage_topics(this.__wbg_ptr);
        var v1 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @returns {number}
     */
    get variant() {
        const ret = wasm.topiccontroldecodedmessage_variant(this.__wbg_ptr);
        return ret;
    }
}
if (Symbol.dispose) TopicControlDecodedMessage.prototype[Symbol.dispose] = TopicControlDecodedMessage.prototype.free;

/**
 * `TopicRootDirectory` root-resolution state (explicit roots + normalized
 * deterministic candidates). Trackers and the resolver callback stay
 * host-side.
 */
export class TopicControlRootDirectory {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        TopicControlRootDirectoryFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_topiccontrolrootdirectory_free(ptr, 0);
    }
    /**
     * @param {string} topic
     */
    delete_root(topic) {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.topiccontrolrootdirectory_delete_root(this.__wbg_ptr, ptr0, len0);
    }
    /**
     * @returns {string[]}
     */
    get_default_candidates() {
        const ret = wasm.topiccontrolrootdirectory_get_default_candidates(this.__wbg_ptr);
        var v1 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
        return v1;
    }
    /**
     * @param {string} topic
     * @returns {string | undefined}
     */
    get_root(topic) {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.topiccontrolrootdirectory_get_root(this.__wbg_ptr, ptr0, len0);
        let v2;
        if (ret[0] !== 0) {
            v2 = getStringFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v2;
    }
    constructor() {
        const ret = wasm.topiccontrolrootdirectory_new();
        this.__wbg_ptr = ret;
        TopicControlRootDirectoryFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
    /**
     * @param {string} topic
     * @returns {string | undefined}
     */
    resolve_deterministic_candidate(topic) {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.topiccontrolrootdirectory_resolve_deterministic_candidate(this.__wbg_ptr, ptr0, len0);
        let v2;
        if (ret[0] !== 0) {
            v2 = getStringFromWasm0(ret[0], ret[1]).slice();
            wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
        }
        return v2;
    }
    /**
     * @param {string[]} candidates
     */
    set_default_candidates(candidates) {
        const ptr0 = passArrayJsValueToWasm0(candidates, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        wasm.topiccontrolrootdirectory_set_default_candidates(this.__wbg_ptr, ptr0, len0);
    }
    /**
     * @param {string} topic
     * @param {string} root
     */
    set_root(topic, root) {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(root, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        wasm.topiccontrolrootdirectory_set_root(this.__wbg_ptr, ptr0, len0, ptr1, len1);
    }
}
if (Symbol.dispose) TopicControlRootDirectory.prototype[Symbol.dispose] = TopicControlRootDirectory.prototype.free;

/**
 * @param {Uint8Array} clock_id
 * @param {Uint8Array} private_key
 * @param {Uint8Array} public_key
 * @param {number} iterations
 * @param {Uint8Array} payload_data
 * @returns {Array<any>}
 */
export function benchmark_entry_v0_storage_verify_modes(clock_id, private_key, public_key, iterations, payload_data) {
    const ret = wasm.benchmark_entry_v0_storage_verify_modes(clock_id, private_key, public_key, iterations, payload_data);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} clock_id
 * @param {Uint8Array} private_key
 * @param {Uint8Array} public_key
 * @param {number} iterations
 * @param {Uint8Array} payload_data
 * @returns {Array<any>}
 */
export function benchmark_plain_entry_v0_core(clock_id, private_key, public_key, iterations, payload_data) {
    const ret = wasm.benchmark_plain_entry_v0_core(clock_id, private_key, public_key, iterations, payload_data);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} clock_id
 * @param {Uint8Array} private_key
 * @param {Uint8Array} public_key
 * @param {number} iterations
 * @param {Uint8Array} payload_data
 * @returns {Array<any>}
 */
export function benchmark_plain_entry_v0_crypto(clock_id, private_key, public_key, iterations, payload_data) {
    const ret = wasm.benchmark_plain_entry_v0_crypto(clock_id, private_key, public_key, iterations, payload_data);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} clock_id
 * @param {Uint8Array} private_key
 * @param {Uint8Array} public_key
 * @param {number} iterations
 * @param {Uint8Array} payload_data
 * @returns {Array<any>}
 */
export function benchmark_plain_entry_v0_digest_key_core(clock_id, private_key, public_key, iterations, payload_data) {
    const ret = wasm.benchmark_plain_entry_v0_digest_key_core(clock_id, private_key, public_key, iterations, payload_data);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * Serialize a `/peerbit/direct-block` `BlockResponse` payload for a block
 * held in the native store. The stored bytes are copied straight into the
 * borsh payload (codec owned by `peerbit_wire::block_exchange`), so serving
 * a natively stored block never materializes the block bytes as a JS value.
 * @param {NativeLogBlockStore} store
 * @param {string} cid
 * @returns {Uint8Array | undefined}
 */
export function block_response_payload(store, cid) {
    _assertClass(store, NativeLogBlockStore);
    const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.block_response_payload(store.__wbg_ptr, ptr0, len0);
    let v2;
    if (ret[0] !== 0) {
        v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
        wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    }
    return v2;
}

/**
 * @param {Uint8Array} bytes
 * @returns {string}
 */
export function calculate_raw_cid_v1(bytes) {
    let deferred1_0;
    let deferred1_1;
    try {
        const ret = wasm.calculate_raw_cid_v1(bytes);
        deferred1_0 = ret[0];
        deferred1_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred1_0, deferred1_1, 1);
    }
}

/**
 * @param {Array<any>} blocks
 * @returns {Array<any>}
 */
export function calculate_raw_cid_v1_batch(blocks) {
    const ret = wasm.calculate_raw_cid_v1_batch(blocks);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * Decode a borsh `BlockMessage` payload (`BlockRequest(0)`/`BlockResponse(1)`).
 * @param {Uint8Array} frame
 * @returns {DirectBlockDecodedMessage}
 */
export function db_decode_block_message(frame) {
    const ptr0 = passArray8ToWasm0(frame, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.db_decode_block_message(ptr0, len0);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return DirectBlockDecodedMessage.__wrap(ret[0]);
}

/**
 * @param {string[]} negotiated
 * @param {string[]} connected
 * @param {string} me
 * @returns {string[]}
 */
export function db_default_provider_candidates(negotiated, connected, me) {
    const ptr0 = passArrayJsValueToWasm0(negotiated, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(connected, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len2 = WASM_VECTOR_LEN;
    const ret = wasm.db_default_provider_candidates(ptr0, len0, ptr1, len1, ptr2, len2);
    var v4 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v4;
}

/**
 * @param {string} cid
 * @returns {Uint8Array}
 */
export function db_encode_block_request(cid) {
    const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.db_encode_block_request(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {string} cid
 * @param {Uint8Array} bytes
 * @returns {Uint8Array}
 */
export function db_encode_block_response(cid, bytes) {
    const ptr0 = passStringToWasm0(cid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArray8ToWasm0(bytes, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.db_encode_block_response(ptr0, len0, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {string[]} providers
 * @param {string} me
 * @param {number} limit
 * @returns {string[]}
 */
export function db_normalize_provider_hints(providers, me, limit) {
    const ptr0 = passArrayJsValueToWasm0(providers, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.db_normalize_provider_hints(ptr0, len0, ptr1, len1, limit);
    var v3 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v3;
}

/**
 * @param {string[]} providers
 * @param {string} me
 * @param {number} attempt
 * @returns {string[]}
 */
export function db_pick_request_batch(providers, me, attempt) {
    const ptr0 = passArrayJsValueToWasm0(providers, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.db_pick_request_batch(ptr0, len0, ptr1, len1, attempt);
    var v3 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v3;
}

/**
 * Decode a batch of direct-stream frames and verify their signatures
 * (sha256-prehashed Ed25519, batched via ed25519-dalek). Returns
 * [`RECORD_WORDS`] u32 words per input frame; see the layout above.
 *
 * `now_ms` is the wall clock used for the header expiry check.
 * @param {Array<any>} frames
 * @param {number} now_ms
 * @returns {Uint32Array}
 */
export function decode_and_verify_batch(frames, now_ms) {
    const ret = wasm.decode_and_verify_batch(frames, now_ms);
    var v1 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v1;
}

/**
 * Decode a frame into the stable debug-JSON shape used by the parity tests.
 * @param {Uint8Array} frame
 * @returns {string}
 */
export function decode_frame_to_json(frame) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passArray8ToWasm0(frame, wasm.__wbindgen_malloc);
        const len0 = WASM_VECTOR_LEN;
        const ret = wasm.decode_frame_to_json(ptr0, len0);
        var ptr2 = ret[0];
        var len2 = ret[1];
        if (ret[3]) {
            ptr2 = 0; len2 = 0;
            throw takeFromExternrefTable0(ret[2]);
        }
        deferred3_0 = ptr2;
        deferred3_1 = len2;
        return getStringFromWasm0(ptr2, len2);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * Returns `[myIndexAsString, nextHop?]`: the first element is our index in
 * the trace ("-1" when absent), the second — present only when there is a
 * previous hop — is the peer to relay the ACK back to.
 * @param {string[]} trace
 * @param {string} me
 * @returns {string[]}
 */
export function ds_ack_next_hop(trace, me) {
    const ptr0 = passArrayJsValueToWasm0(trace, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ds_ack_next_hop(ptr0, len0, ptr1, len1);
    var v3 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v3;
}

/**
 * @param {string[]} candidates
 * @param {string} from
 * @param {string[]} signed
 * @param {string[]} hops
 * @returns {Uint32Array}
 */
export function ds_filter_flood_targets(candidates, from, signed, hops) {
    const ptr0 = passArrayJsValueToWasm0(candidates, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passArrayJsValueToWasm0(signed, wasm.__wbindgen_malloc);
    const len2 = WASM_VECTOR_LEN;
    const ptr3 = passArrayJsValueToWasm0(hops, wasm.__wbindgen_malloc);
    const len3 = WASM_VECTOR_LEN;
    const ret = wasm.ds_filter_flood_targets(ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3);
    var v5 = getArrayU32FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v5;
}

/**
 * @param {string[]} recipients
 * @param {string} me
 * @param {string} from
 * @param {string[]} connected
 * @param {string[]} hops
 * @returns {string[]}
 */
export function ds_filter_silent_relay_recipients(recipients, me, from, connected, hops) {
    const ptr0 = passArrayJsValueToWasm0(recipients, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passStringToWasm0(from, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len2 = WASM_VECTOR_LEN;
    const ptr3 = passArrayJsValueToWasm0(connected, wasm.__wbindgen_malloc);
    const len3 = WASM_VECTOR_LEN;
    const ptr4 = passArrayJsValueToWasm0(hops, wasm.__wbindgen_malloc);
    const len4 = WASM_VECTOR_LEN;
    const ret = wasm.ds_filter_silent_relay_recipients(ptr0, len0, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4);
    var v6 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v6;
}

/**
 * Returns `[from, neighbour]` — the route edge to learn from an ACK.
 * @param {string} current
 * @param {string | null | undefined} upstream
 * @param {string} downstream
 * @returns {string[]}
 */
export function ds_seek_ack_route_update(current, upstream, downstream) {
    const ptr0 = passStringToWasm0(current, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    var ptr1 = isLikeNone(upstream) ? 0 : passStringToWasm0(upstream, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    var len1 = WASM_VECTOR_LEN;
    const ptr2 = passStringToWasm0(downstream, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len2 = WASM_VECTOR_LEN;
    const ret = wasm.ds_seek_ack_route_update(ptr0, len0, ptr1, len1, ptr2, len2);
    var v4 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v4;
}

/**
 * @param {string[]} peers
 * @param {string[]} used
 * @param {number} redundancy
 * @returns {string[]}
 */
export function ds_select_redundancy_probes(peers, used, redundancy) {
    const ptr0 = passArrayJsValueToWasm0(peers, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(used, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ds_select_redundancy_probes(ptr0, len0, ptr1, len1, redundancy);
    var v3 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v3;
}

/**
 * @param {boolean} is_recipient
 * @param {number} seen_before
 * @param {number} redundancy
 * @returns {boolean}
 */
export function ds_should_acknowledge(is_recipient, seen_before, redundancy) {
    const ret = wasm.ds_should_acknowledge(is_recipient, seen_before, redundancy);
    return ret !== 0;
}

/**
 * @param {number} seen_before
 * @param {boolean} acknowledged_mode
 * @param {number} redundancy
 * @param {string[]} hops
 * @param {string} me
 * @param {boolean} signed_by_self
 * @returns {boolean}
 */
export function ds_should_ignore_data(seen_before, acknowledged_mode, redundancy, hops, me, signed_by_self) {
    const ptr0 = passArrayJsValueToWasm0(hops, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ds_should_ignore_data(seen_before, acknowledged_mode, redundancy, ptr0, len0, ptr1, len1, signed_by_self);
    return ret !== 0;
}

/**
 * @param {Uint8Array} clock_id
 * @param {bigint} wall_time
 * @param {number} logical
 * @param {string} gid
 * @param {Array<any>} next
 * @param {number} entry_type
 * @param {any} meta_data
 * @param {Uint8Array} payload_data
 * @returns {Uint8Array}
 */
export function encode_entry_v0_signable(clock_id, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
    const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.encode_entry_v0_signable(clock_id, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Array<any>} clock_ids
 * @param {BigUint64Array} wall_times
 * @param {Uint32Array} logicals
 * @param {Array<any>} gids
 * @param {Array<any>} nexts
 * @param {Uint8Array} entry_types
 * @param {Array<any>} meta_datas
 * @param {Array<any>} payload_datas
 * @returns {Array<any>}
 */
export function encode_entry_v0_signable_batch(clock_ids, wall_times, logicals, gids, nexts, entry_types, meta_datas, payload_datas) {
    const ret = wasm.encode_entry_v0_signable_batch(clock_ids, wall_times, logicals, gids, nexts, entry_types, meta_datas, payload_datas);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} clock_id
 * @param {bigint} wall_time
 * @param {number} logical
 * @param {string} gid
 * @param {Array<any>} next
 * @param {number} entry_type
 * @param {any} meta_data
 * @param {Uint8Array} payload_data
 * @param {Uint8Array} signature
 * @param {Uint8Array} signature_public_key
 * @param {number} prehash
 * @returns {Uint8Array}
 */
export function encode_entry_v0_storage(clock_id, wall_time, logical, gid, next, entry_type, meta_data, payload_data, signature, signature_public_key, prehash) {
    const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.encode_entry_v0_storage(clock_id, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, signature, signature_public_key, prehash);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Array<any>} clock_ids
 * @param {BigUint64Array} wall_times
 * @param {Uint32Array} logicals
 * @param {Array<any>} gids
 * @param {Array<any>} nexts
 * @param {Uint8Array} entry_types
 * @param {Array<any>} meta_datas
 * @param {Array<any>} payload_datas
 * @param {Array<any>} signatures
 * @param {Array<any>} signature_public_keys
 * @param {Uint8Array} prehashes
 * @returns {Array<any>}
 */
export function encode_entry_v0_storage_batch_with_cids(clock_ids, wall_times, logicals, gids, nexts, entry_types, meta_datas, payload_datas, signatures, signature_public_keys, prehashes) {
    const ret = wasm.encode_entry_v0_storage_batch_with_cids(clock_ids, wall_times, logicals, gids, nexts, entry_types, meta_datas, payload_datas, signatures, signature_public_keys, prehashes);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} clock_id
 * @param {bigint} wall_time
 * @param {number} logical
 * @param {string} gid
 * @param {Array<any>} next
 * @param {number} entry_type
 * @param {any} meta_data
 * @param {Uint8Array} payload_data
 * @param {Uint8Array} signature
 * @param {Uint8Array} signature_public_key
 * @param {number} prehash
 * @returns {Array<any>}
 */
export function encode_entry_v0_storage_with_cid(clock_id, wall_time, logical, gid, next, entry_type, meta_data, payload_data, signature, signature_public_key, prehash) {
    const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.encode_entry_v0_storage_with_cid(clock_id, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data, signature, signature_public_key, prehash);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} bytes
 * @returns {Uint8Array}
 */
export function entry_v0_plain_payload_data_from_storage(bytes) {
    const ret = wasm.entry_v0_plain_payload_data_from_storage(bytes);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_end(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_end(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_ihave(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_ihave(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_join_accept(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_join_accept(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_join_reject(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_join_reject(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_join_req(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_join_req(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_join_response_req_id(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_join_response_req_id(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_parent_probe_reply(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_parent_probe_reply(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_parent_probe_req(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_parent_probe_req(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_provider_announce(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_provider_announce(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_provider_notify(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_provider_notify(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_provider_query(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_provider_query(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_provider_reply(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_provider_reply(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_provider_subscribe(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_provider_subscribe(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_repair_seqs(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_repair_seqs(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_route_query(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_route_query(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_route_reply(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_route_reply(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_tracker_announce(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_tracker_announce(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_tracker_feedback(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_tracker_feedback(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_tracker_query(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_tracker_query(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_tracker_reply(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_tracker_reply(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_unicast(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_unicast(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} data
 * @returns {FanoutTreeDecodedFrame | undefined}
 */
export function ft_decode_unicast_ack(data) {
    const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_decode_unicast_ack(ptr0, len0);
    return ret === 0 ? undefined : FanoutTreeDecodedFrame.__wrap(ret);
}

/**
 * @param {Uint8Array} payload
 * @returns {Uint8Array}
 */
export function ft_encode_data(payload) {
    const ptr0 = passArray8ToWasm0(payload, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_data(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} last_seq_exclusive
 * @returns {Uint8Array}
 */
export function ft_encode_end(channel_key, last_seq_exclusive) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_end(ptr0, len0, last_seq_exclusive);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {Float64Array} missing_seqs
 * @returns {Uint8Array}
 */
export function ft_encode_fetch_req(channel_key, req_id, missing_seqs) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayF64ToWasm0(missing_seqs, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_fetch_req(ptr0, len0, req_id, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} have_from
 * @param {number} have_to_exclusive
 * @returns {Uint8Array}
 */
export function ft_encode_ihave(channel_key, have_from, have_to_exclusive) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_ihave(ptr0, len0, have_from, have_to_exclusive);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {number} level
 * @param {string[]} parent_route_from_root
 * @param {boolean} has_have_range
 * @param {number} have_from
 * @param {number} have_to_exclusive
 * @returns {Uint8Array}
 */
export function ft_encode_join_accept(channel_key, req_id, level, parent_route_from_root, has_have_range, have_from, have_to_exclusive) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(parent_route_from_root, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_join_accept(ptr0, len0, req_id, level, ptr1, len1, has_have_range, have_from, have_to_exclusive);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {number} reason
 * @param {string[]} redirect_hashes
 * @param {Uint32Array} redirect_addr_counts
 * @param {Array<any>} redirect_addrs
 * @returns {Uint8Array}
 */
export function ft_encode_join_reject(channel_key, req_id, reason, redirect_hashes, redirect_addr_counts, redirect_addrs) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(redirect_hashes, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passArray32ToWasm0(redirect_addr_counts, wasm.__wbindgen_malloc);
    const len2 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_join_reject(ptr0, len0, req_id, reason, ptr1, len1, ptr2, len2, redirect_addrs);
    var v4 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v4;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {number} bid_per_byte
 * @param {number} parent_upgrade_reservation_token
 * @returns {Uint8Array}
 */
export function ft_encode_join_req(channel_key, req_id, bid_per_byte, parent_upgrade_reservation_token) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_join_req(ptr0, len0, req_id, bid_per_byte, parent_upgrade_reservation_token);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @returns {Uint8Array}
 */
export function ft_encode_kick(channel_key) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_kick(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @returns {Uint8Array}
 */
export function ft_encode_leave(channel_key) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_leave(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {number} flags
 * @param {number} level
 * @param {number} max_children
 * @param {number} free_slots
 * @param {number} children
 * @param {number} have_to_exclusive
 * @param {number} missing_seqs
 * @param {number} data_write_drops
 * @param {number} dropped_forwards
 * @param {number} reservation_token
 * @returns {Uint8Array}
 */
export function ft_encode_parent_probe_reply(channel_key, req_id, flags, level, max_children, free_slots, children, have_to_exclusive, missing_seqs, data_write_drops, dropped_forwards, reservation_token) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_parent_probe_reply(ptr0, len0, req_id, flags, level, max_children, free_slots, children, have_to_exclusive, missing_seqs, data_write_drops, dropped_forwards, reservation_token);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {number} min_free_slots
 * @param {boolean} reserve_root_capacity
 * @returns {Uint8Array}
 */
export function ft_encode_parent_probe_req(channel_key, req_id, min_free_slots, reserve_root_capacity) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_parent_probe_req(ptr0, len0, req_id, min_free_slots, reserve_root_capacity);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} namespace_key
 * @param {number} ttl_ms
 * @param {Array<any>} addrs
 * @returns {Uint8Array}
 */
export function ft_encode_provider_announce(namespace_key, ttl_ms, addrs) {
    const ptr0 = passArray8ToWasm0(namespace_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_provider_announce(ptr0, len0, ttl_ms, addrs);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} namespace_key
 * @param {string[]} entry_hashes
 * @param {Uint32Array} entry_addr_counts
 * @param {Array<any>} entry_addrs
 * @returns {Uint8Array}
 */
export function ft_encode_provider_notify(namespace_key, entry_hashes, entry_addr_counts, entry_addrs) {
    const ptr0 = passArray8ToWasm0(namespace_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(entry_hashes, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passArray32ToWasm0(entry_addr_counts, wasm.__wbindgen_malloc);
    const len2 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_provider_notify(ptr0, len0, ptr1, len1, ptr2, len2, entry_addrs);
    var v4 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v4;
}

/**
 * @param {Uint8Array} namespace_key
 * @param {number} req_id
 * @param {number} want
 * @param {number} seed
 * @returns {Uint8Array}
 */
export function ft_encode_provider_query(namespace_key, req_id, want, seed) {
    const ptr0 = passArray8ToWasm0(namespace_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_provider_query(ptr0, len0, req_id, want, seed);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} namespace_key
 * @param {number} req_id
 * @param {string[]} entry_hashes
 * @param {Uint32Array} entry_addr_counts
 * @param {Array<any>} entry_addrs
 * @returns {Uint8Array}
 */
export function ft_encode_provider_reply(namespace_key, req_id, entry_hashes, entry_addr_counts, entry_addrs) {
    const ptr0 = passArray8ToWasm0(namespace_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(entry_hashes, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passArray32ToWasm0(entry_addr_counts, wasm.__wbindgen_malloc);
    const len2 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_provider_reply(ptr0, len0, req_id, ptr1, len1, ptr2, len2, entry_addrs);
    var v4 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v4;
}

/**
 * @param {Uint8Array} namespace_key
 * @param {number} want
 * @param {number} ttl_ms
 * @returns {Uint8Array}
 */
export function ft_encode_provider_subscribe(namespace_key, want, ttl_ms) {
    const ptr0 = passArray8ToWasm0(namespace_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_provider_subscribe(ptr0, len0, want, ttl_ms);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} namespace_key
 * @returns {Uint8Array}
 */
export function ft_encode_provider_unsubscribe(namespace_key) {
    const ptr0 = passArray8ToWasm0(namespace_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_provider_unsubscribe(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {Uint8Array} payload
 * @returns {Uint8Array}
 */
export function ft_encode_publish_proxy(channel_key, payload) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArray8ToWasm0(payload, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_publish_proxy(ptr0, len0, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {Float64Array} missing_seqs
 * @returns {Uint8Array}
 */
export function ft_encode_repair_req(channel_key, req_id, missing_seqs) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayF64ToWasm0(missing_seqs, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_repair_req(ptr0, len0, req_id, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {string} target_hash
 * @returns {Uint8Array}
 */
export function ft_encode_route_query(channel_key, req_id, target_hash) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(target_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_route_query(ptr0, len0, req_id, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {string[]} route
 * @returns {Uint8Array}
 */
export function ft_encode_route_reply(channel_key, req_id, route) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(route, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_route_reply(ptr0, len0, req_id, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} ttl_ms
 * @param {number} level
 * @param {number} max_children
 * @param {number} free_slots
 * @param {number} bid_per_byte
 * @param {Array<any>} addrs
 * @returns {Uint8Array}
 */
export function ft_encode_tracker_announce(channel_key, ttl_ms, level, max_children, free_slots, bid_per_byte, addrs) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_tracker_announce(ptr0, len0, ttl_ms, level, max_children, free_slots, bid_per_byte, addrs);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {string} candidate_hash
 * @param {number} event
 * @param {number} reason
 * @returns {Uint8Array}
 */
export function ft_encode_tracker_feedback(channel_key, candidate_hash, event, reason) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(candidate_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_tracker_feedback(ptr0, len0, ptr1, len1, event, reason);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {number} want
 * @returns {Uint8Array}
 */
export function ft_encode_tracker_query(channel_key, req_id, want) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_tracker_query(ptr0, len0, req_id, want);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} channel_key
 * @param {number} req_id
 * @param {string[]} entry_hashes
 * @param {Float64Array} entry_levels
 * @param {Float64Array} entry_free_slots
 * @param {Float64Array} entry_bids
 * @param {Uint32Array} entry_addr_counts
 * @param {Array<any>} entry_addrs
 * @returns {Uint8Array}
 */
export function ft_encode_tracker_reply(channel_key, req_id, entry_hashes, entry_levels, entry_free_slots, entry_bids, entry_addr_counts, entry_addrs) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(entry_hashes, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passArrayF64ToWasm0(entry_levels, wasm.__wbindgen_malloc);
    const len2 = WASM_VECTOR_LEN;
    const ptr3 = passArrayF64ToWasm0(entry_free_slots, wasm.__wbindgen_malloc);
    const len3 = WASM_VECTOR_LEN;
    const ptr4 = passArrayF64ToWasm0(entry_bids, wasm.__wbindgen_malloc);
    const len4 = WASM_VECTOR_LEN;
    const ptr5 = passArray32ToWasm0(entry_addr_counts, wasm.__wbindgen_malloc);
    const len5 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_tracker_reply(ptr0, len0, req_id, ptr1, len1, ptr2, len2, ptr3, len3, ptr4, len4, ptr5, len5, entry_addrs);
    var v7 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v7;
}

/**
 * @param {Uint8Array} channel_key
 * @param {string[]} route
 * @param {Uint8Array} payload
 * @param {boolean} has_ack
 * @param {bigint} ack_token
 * @param {string[]} reply_route
 * @returns {Uint8Array}
 */
export function ft_encode_unicast(channel_key, route, payload, has_ack, ack_token, reply_route) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(route, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ptr2 = passArray8ToWasm0(payload, wasm.__wbindgen_malloc);
    const len2 = WASM_VECTOR_LEN;
    const ptr3 = passArrayJsValueToWasm0(reply_route, wasm.__wbindgen_malloc);
    const len3 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_unicast(ptr0, len0, ptr1, len1, ptr2, len2, has_ack, ack_token, ptr3, len3);
    var v5 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v5;
}

/**
 * @param {Uint8Array} channel_key
 * @param {bigint} ack_token
 * @param {string[]} route
 * @returns {Uint8Array}
 */
export function ft_encode_unicast_ack(channel_key, ack_token, route) {
    const ptr0 = passArray8ToWasm0(channel_key, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(route, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.ft_encode_unicast_ack(ptr0, len0, ack_token, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * `evaluateParentUpgradeGate`; returns the skip-reason code in the low
 * byte (0 = run) plus the retry-after-seq reset flag (0x100).
 * @param {number} children_size
 * @param {number} missing_seqs_size
 * @param {number} last_repair_sent_at
 * @param {number} end_seq_exclusive
 * @param {number} parent_upgrade_retry_after_seq
 * @param {number} max_seq_seen
 * @param {number} parent_upgrade_count
 * @param {number} parent_upgrade_backoff_until
 * @param {number} parent_upgrade_last_at
 * @param {number} last_parent_data_at
 * @param {number} last_parent_upgrade_activity_at
 * @param {boolean} leaf_only
 * @param {boolean} repair_guard
 * @param {boolean} data_guard
 * @param {boolean} ended_and_complete
 * @param {number} max_per_peer
 * @param {number} cooldown_ms
 * @param {number} quiet_ms
 * @param {number} repair_quiet_ms
 * @param {number} now
 * @returns {number}
 */
export function ft_pu_evaluate_gate(children_size, missing_seqs_size, last_repair_sent_at, end_seq_exclusive, parent_upgrade_retry_after_seq, max_seq_seen, parent_upgrade_count, parent_upgrade_backoff_until, parent_upgrade_last_at, last_parent_data_at, last_parent_upgrade_activity_at, leaf_only, repair_guard, data_guard, ended_and_complete, max_per_peer, cooldown_ms, quiet_ms, repair_quiet_ms, now) {
    const ret = wasm.ft_pu_evaluate_gate(children_size, missing_seqs_size, last_repair_sent_at, end_seq_exclusive, parent_upgrade_retry_after_seq, max_seq_seen, parent_upgrade_count, parent_upgrade_backoff_until, parent_upgrade_last_at, last_parent_data_at, last_parent_upgrade_activity_at, leaf_only, repair_guard, data_guard, ended_and_complete, max_per_peer, cooldown_ms, quiet_ms, repair_quiet_ms, now);
    return ret >>> 0;
}

/**
 * `normalizeParentUpgradePolicy` over the fixed-order f64 protocol
 * documented in `fanout_tree.rs` (numeric options gated by the presence
 * bitmask at index 30 so an explicit NaN flows through like TS, -1/0/1
 * tri-state booleans, mode 0 unset / 1 direct / 2 probe / 3 shadow).
 * @param {Float64Array} options
 * @returns {Float64Array}
 */
export function ft_pu_normalize_policy(options) {
    const ptr0 = passArrayF64ToWasm0(options, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.ft_pu_normalize_policy(ptr0, len0);
    var v2 = getArrayF64FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 8, 8);
    return v2;
}

/**
 * @param {Uint8Array} clock_id
 * @param {Uint8Array} private_key
 * @param {Uint8Array} public_key
 * @param {BigUint64Array} wall_times
 * @param {Uint32Array} logicals
 * @param {string} gid
 * @param {Array<any>} initial_next
 * @param {number} entry_type
 * @param {Array<any>} meta_datas
 * @param {Array<any>} payload_datas
 * @returns {Array<any>}
 */
export function prepare_entry_v0_plain_chain(clock_id, private_key, public_key, wall_times, logicals, gid, initial_next, entry_type, meta_datas, payload_datas) {
    const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.prepare_entry_v0_plain_chain(clock_id, private_key, public_key, wall_times, logicals, ptr0, len0, initial_next, entry_type, meta_datas, payload_datas);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Uint8Array} clock_id
 * @param {Uint8Array} private_key
 * @param {Uint8Array} public_key
 * @param {bigint} wall_time
 * @param {number} logical
 * @param {string} gid
 * @param {Array<any>} next
 * @param {number} entry_type
 * @param {any} meta_data
 * @param {Uint8Array} payload_data
 * @returns {Array<any>}
 */
export function prepare_entry_v0_plain_entry(clock_id, private_key, public_key, wall_time, logical, gid, next, entry_type, meta_data, payload_data) {
    const ptr0 = passStringToWasm0(gid, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.prepare_entry_v0_plain_entry(clock_id, private_key, public_key, wall_time, logical, ptr0, len0, next, entry_type, meta_data, payload_data);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Array<any>} blocks
 * @returns {Array<any>}
 */
export function prepare_raw_entry_v0_batch(blocks) {
    const ret = wasm.prepare_raw_entry_v0_batch(blocks);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * Decode a frame and re-encode it from the parsed representation. Used by
 * the golden-vector parity tests to prove Rust encoding is byte-identical
 * to the TS wire format.
 * @param {Uint8Array} frame
 * @returns {Uint8Array}
 */
export function reencode_frame(frame) {
    const ptr0 = passArray8ToWasm0(frame, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.reencode_frame(ptr0, len0);
    if (ret[3]) {
        throw takeFromExternrefTable0(ret[2]);
    }
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {Uint8Array} private_key
 * @param {Uint8Array} public_key
 * @param {Uint8Array} data
 * @returns {Uint8Array}
 */
export function sign_ed25519(private_key, public_key, data) {
    const ret = wasm.sign_ed25519(private_key, public_key, data);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * The signable byte range of a frame: the serialized message with the
 * delivery mode and signatures excluded (both are mutated in transit).
 * Must match `Message.getSignableBytes()` in the TS implementation.
 * @param {Uint8Array} frame
 * @returns {Uint8Array}
 */
export function signable_bytes(frame) {
    const ptr0 = passArray8ToWasm0(frame, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.signable_bytes(ptr0, len0);
    if (ret[3]) {
        throw takeFromExternrefTable0(ret[2]);
    }
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * Decode a borsh `PubSubMessage` payload (variants 0-7).
 * @param {Uint8Array} frame
 * @returns {TopicControlDecodedMessage}
 */
export function tc_decode_pubsub_message(frame) {
    const ptr0 = passArray8ToWasm0(frame, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_decode_pubsub_message(ptr0, len0);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return TopicControlDecodedMessage.__wrap(ret[0]);
}

/**
 * @param {string[]} topics
 * @returns {Uint8Array}
 */
export function tc_encode_get_subscribers(topics) {
    const ptr0 = passArrayJsValueToWasm0(topics, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_get_subscribers(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {string} public_key_hash
 * @param {bigint} session
 * @param {bigint} timestamp
 * @param {string[]} topics
 * @returns {Uint8Array}
 */
export function tc_encode_peer_unavailable(public_key_hash, session, timestamp, topics) {
    const ptr0 = passStringToWasm0(public_key_hash, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArrayJsValueToWasm0(topics, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_peer_unavailable(ptr0, len0, session, timestamp, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {string[]} topics
 * @param {boolean} strict
 * @param {Uint8Array} data
 * @returns {Uint8Array}
 */
export function tc_encode_pubsub_data(topics, strict, data) {
    const ptr0 = passArrayJsValueToWasm0(topics, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_pubsub_data(ptr0, len0, strict, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {string[]} topics
 * @param {boolean} request_subscribers
 * @returns {Uint8Array}
 */
export function tc_encode_subscribe(topics, request_subscribers) {
    const ptr0 = passArrayJsValueToWasm0(topics, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_subscribe(ptr0, len0, request_subscribers);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {string[]} candidates
 * @returns {Uint8Array}
 */
export function tc_encode_topic_root_candidates(candidates) {
    const ptr0 = passArrayJsValueToWasm0(candidates, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_topic_root_candidates(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {number} request_id
 * @param {string} topic
 * @returns {Uint8Array}
 */
export function tc_encode_topic_root_query(request_id, topic) {
    const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_topic_root_query(request_id, ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {number} request_id
 * @param {string} topic
 * @param {string | null} [root]
 * @returns {Uint8Array}
 */
export function tc_encode_topic_root_query_response(request_id, topic, root) {
    const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    var ptr1 = isLikeNone(root) ? 0 : passStringToWasm0(root, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    var len1 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_topic_root_query_response(request_id, ptr0, len0, ptr1, len1);
    var v3 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v3;
}

/**
 * @param {string[]} topics
 * @returns {Uint8Array}
 */
export function tc_encode_unsubscribe(topics) {
    const ptr0 = passArrayJsValueToWasm0(topics, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_encode_unsubscribe(ptr0, len0);
    var v2 = getArrayU8FromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 1, 1);
    return v2;
}

/**
 * @param {string[]} candidates
 * @param {string} me
 * @returns {string[]}
 */
export function tc_normalize_auto_candidates(candidates, me) {
    const ptr0 = passArrayJsValueToWasm0(candidates, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ptr1 = passStringToWasm0(me, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len1 = WASM_VECTOR_LEN;
    const ret = wasm.tc_normalize_auto_candidates(ptr0, len0, ptr1, len1);
    var v3 = getArrayJsValueFromWasm0(ret[0], ret[1]).slice();
    wasm.__wbindgen_free(ret[0], ret[1] * 4, 4);
    return v3;
}

/**
 * @param {string} topic
 * @param {number} shard_count
 * @param {string} prefix
 * @returns {string}
 */
export function tc_shard_topic(topic, shard_count, prefix) {
    let deferred3_0;
    let deferred3_1;
    try {
        const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len0 = WASM_VECTOR_LEN;
        const ptr1 = passStringToWasm0(prefix, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
        const len1 = WASM_VECTOR_LEN;
        const ret = wasm.tc_shard_topic(ptr0, len0, shard_count, ptr1, len1);
        deferred3_0 = ret[0];
        deferred3_1 = ret[1];
        return getStringFromWasm0(ret[0], ret[1]);
    } finally {
        wasm.__wbindgen_free(deferred3_0, deferred3_1, 1);
    }
}

/**
 * @param {bigint | null | undefined} existing_session
 * @param {bigint} session
 * @returns {boolean}
 */
export function tc_subscribe_should_replace(existing_session, session) {
    const ret = wasm.tc_subscribe_should_replace(!isLikeNone(existing_session), isLikeNone(existing_session) ? BigInt(0) : existing_session, session);
    return ret !== 0;
}

/**
 * `lasts` carries interleaved (session, timestamp) watermark pairs for the
 * relevant topics that have one; see `subscription_is_latest`.
 * @param {BigUint64Array} lasts
 * @param {bigint} session
 * @param {bigint} timestamp
 * @returns {boolean}
 */
export function tc_subscription_is_latest(lasts, session, timestamp) {
    const ptr0 = passArray64ToWasm0(lasts, wasm.__wbindgen_malloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_subscription_is_latest(ptr0, len0, session, timestamp);
    return ret !== 0;
}

/**
 * @param {string} topic
 * @returns {number}
 */
export function tc_topic_hash32(topic) {
    const ptr0 = passStringToWasm0(topic, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
    const len0 = WASM_VECTOR_LEN;
    const ret = wasm.tc_topic_hash32(ptr0, len0);
    return ret >>> 0;
}

/**
 * Deterministic Rust-authored golden vectors for the reverse parity
 * direction (Rust encode → TS decode). See `wire::build_test_corpus`.
 * @returns {Array<any>}
 */
export function test_corpus_frames() {
    const ret = wasm.test_corpus_frames();
    return ret;
}

/**
 * @param {Array<any>} signatures
 * @param {Array<any>} public_keys
 * @param {Array<any>} messages
 * @returns {Uint8Array}
 */
export function verify_ed25519_batch(signatures, public_keys, messages) {
    const ret = wasm.verify_ed25519_batch(signatures, public_keys, messages);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Array<any>} clock_ids
 * @param {BigUint64Array} wall_times
 * @param {Uint32Array} logicals
 * @param {Array<any>} gids
 * @param {Array<any>} nexts
 * @param {Uint8Array} entry_types
 * @param {Array<any>} meta_datas
 * @param {Array<any>} payload_datas
 * @param {Array<any>} signatures
 * @param {Array<any>} public_keys
 * @returns {Uint8Array}
 */
export function verify_entry_v0_ed25519_batch(clock_ids, wall_times, logicals, gids, nexts, entry_types, meta_datas, payload_datas, signatures, public_keys) {
    const ret = wasm.verify_entry_v0_ed25519_batch(clock_ids, wall_times, logicals, gids, nexts, entry_types, meta_datas, payload_datas, signatures, public_keys);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}

/**
 * @param {Array<any>} blocks
 * @returns {Uint8Array}
 */
export function verify_entry_v0_ed25519_storage_batch(blocks) {
    const ret = wasm.verify_entry_v0_ed25519_storage_batch(blocks);
    if (ret[2]) {
        throw takeFromExternrefTable0(ret[1]);
    }
    return takeFromExternrefTable0(ret[0]);
}
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
        __wbg___wbindgen_rethrow_2b7cc655458909c2: function(arg0) {
            throw arg0;
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
        __wbg_get_dcf82ab8aad1a593: function() { return handleError(function (arg0, arg1) {
            const ret = Reflect.get(arg0, arg1);
            return ret;
        }, arguments); },
        __wbg_get_index_c051becca25aa6d8: function(arg0, arg1) {
            const ret = arg0[arg1 >>> 0];
            return ret;
        },
        __wbg_get_index_c48691d6b5993df9: function(arg0, arg1) {
            const ret = arg0[arg1 >>> 0];
            return ret;
        },
        __wbg_get_index_da563bdf9de384a6: function(arg0, arg1) {
            const ret = arg0[arg1 >>> 0];
            return ret;
        },
        __wbg_get_unchecked_1dfe6d05ad91d9b7: function(arg0, arg1) {
            const ret = arg0[arg1 >>> 0];
            return ret;
        },
        __wbg_instanceof_Uint8Array_abd07d4bd221d50b: function(arg0) {
            let result;
            try {
                result = arg0 instanceof Uint8Array;
            } catch (_) {
                result = false;
            }
            const ret = result;
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
        __wbg_length_3a1b902b6cde9e2c: function(arg0) {
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
        __wbg_new_7ddec6de44ff8f5d: function(arg0) {
            const ret = new Uint8Array(arg0);
            return ret;
        },
        __wbg_new_from_slice_269e35316ed2d061: function(arg0, arg1) {
            const ret = new Uint8Array(getArrayU8FromWasm0(arg0, arg1));
            return ret;
        },
        __wbg_new_from_slice_488f0668f819d09d: function(arg0, arg1) {
            const ret = new BigUint64Array(getArrayU64FromWasm0(arg0, arg1));
            return ret;
        },
        __wbg_new_from_slice_f92bf65e9a895613: function(arg0, arg1) {
            const ret = new Uint32Array(getArrayU32FromWasm0(arg0, arg1));
            return ret;
        },
        __wbg_new_with_length_c2a8f9ac6aaaac03: function(arg0) {
            const ret = new Array(arg0 >>> 0);
            return ret;
        },
        __wbg_now_81363d44c96dd239: function() {
            const ret = Date.now();
            return ret;
        },
        __wbg_prototypesetcall_303283bf37c9f014: function(arg0, arg1, arg2) {
            Uint32Array.prototype.set.call(getArrayU32FromWasm0(arg0, arg1), arg2);
        },
        __wbg_prototypesetcall_5f9bdc8d75e07276: function(arg0, arg1, arg2) {
            Uint8Array.prototype.set.call(getArrayU8FromWasm0(arg0, arg1), arg2);
        },
        __wbg_prototypesetcall_e8ac1641c06469bb: function(arg0, arg1, arg2) {
            BigUint64Array.prototype.set.call(getArrayU64FromWasm0(arg0, arg1), arg2);
        },
        __wbg_push_b77c476b01548d0a: function(arg0, arg1) {
            const ret = arg0.push(arg1);
            return ret;
        },
        __wbg_set_78ea6a19f4818587: function(arg0, arg1, arg2) {
            arg0[arg1 >>> 0] = arg2;
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
        "./native_backbone_bg.js": import0,
    };
}

const DirectBlockDecodedMessageFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_directblockdecodedmessage_free(ptr, 1));
const DirectBlockEagerIndexFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_directblockeagerindex_free(ptr, 1));
const DirectBlockProviderCacheFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_directblockprovidercache_free(ptr, 1));
const DirectStreamLanesFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_directstreamlanes_free(ptr, 1));
const DirectStreamRoutesFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_directstreamroutes_free(ptr, 1));
const DirectStreamSeenCacheFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_directstreamseencache_free(ptr, 1));
const FanoutTreeDecodedFrameFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_fanouttreedecodedframe_free(ptr, 1));
const NativeDurabilityJournalCodecFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativedurabilityjournalcodec_free(ptr, 1));
const NativeEntryV0PlainBuilderFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativeentryv0plainbuilder_free(ptr, 1));
const NativeLogBlockStoreFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativelogblockstore_free(ptr, 1));
const NativeLogIndexFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativelogindex_free(ptr, 1));
const NativePeerbitBackboneFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativepeerbitbackbone_free(ptr, 1));
const NativeRangePlannerFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativerangeplanner_free(ptr, 1));
const NativeSharedLogStateFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativesharedlogstate_free(ptr, 1));
const NativeWireSyncSessionFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_nativewiresyncsession_free(ptr, 1));
const TopicControlDecodedMessageFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_topiccontroldecodedmessage_free(ptr, 1));
const TopicControlRootDirectoryFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_topiccontrolrootdirectory_free(ptr, 1));

function addToExternrefTable0(obj) {
    const idx = wasm.__externref_table_alloc();
    wasm.__wbindgen_externrefs.set(idx, obj);
    return idx;
}

function _assertClass(instance, klass) {
    if (!(instance instanceof klass)) {
        throw new Error(`expected instance of ${klass.name}`);
    }
}

function getArrayF64FromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return getFloat64ArrayMemory0().subarray(ptr / 8, ptr / 8 + len);
}

function getArrayJsValueFromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    const mem = getDataViewMemory0();
    const result = [];
    for (let i = ptr; i < ptr + 4 * len; i += 4) {
        result.push(wasm.__wbindgen_externrefs.get(mem.getUint32(i, true)));
    }
    wasm.__externref_drop_slice(ptr, len);
    return result;
}

function getArrayU32FromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return getUint32ArrayMemory0().subarray(ptr / 4, ptr / 4 + len);
}

function getArrayU64FromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return getBigUint64ArrayMemory0().subarray(ptr / 8, ptr / 8 + len);
}

function getArrayU8FromWasm0(ptr, len) {
    ptr = ptr >>> 0;
    return getUint8ArrayMemory0().subarray(ptr / 1, ptr / 1 + len);
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

let cachedFloat64ArrayMemory0 = null;
function getFloat64ArrayMemory0() {
    if (cachedFloat64ArrayMemory0 === null || cachedFloat64ArrayMemory0.byteLength === 0) {
        cachedFloat64ArrayMemory0 = new Float64Array(wasm.memory.buffer);
    }
    return cachedFloat64ArrayMemory0;
}

function getStringFromWasm0(ptr, len) {
    return decodeText(ptr >>> 0, len);
}

let cachedUint32ArrayMemory0 = null;
function getUint32ArrayMemory0() {
    if (cachedUint32ArrayMemory0 === null || cachedUint32ArrayMemory0.byteLength === 0) {
        cachedUint32ArrayMemory0 = new Uint32Array(wasm.memory.buffer);
    }
    return cachedUint32ArrayMemory0;
}

let cachedUint8ArrayMemory0 = null;
function getUint8ArrayMemory0() {
    if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
        cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachedUint8ArrayMemory0;
}

function handleError(f, args) {
    try {
        return f.apply(this, args);
    } catch (e) {
        const idx = addToExternrefTable0(e);
        wasm.__wbindgen_exn_store(idx);
    }
}

function isLikeNone(x) {
    return x === undefined || x === null;
}

function passArray32ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 4, 4) >>> 0;
    getUint32ArrayMemory0().set(arg, ptr / 4);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

function passArray64ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 8, 8) >>> 0;
    getBigUint64ArrayMemory0().set(arg, ptr / 8);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

function passArray8ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 1, 1) >>> 0;
    getUint8ArrayMemory0().set(arg, ptr / 1);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

function passArrayF64ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 8, 8) >>> 0;
    getFloat64ArrayMemory0().set(arg, ptr / 8);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

function passArrayJsValueToWasm0(array, malloc) {
    const ptr = malloc(array.length * 4, 4) >>> 0;
    for (let i = 0; i < array.length; i++) {
        const add = addToExternrefTable0(array[i]);
        getDataViewMemory0().setUint32(ptr + 4 * i, add, true);
    }
    WASM_VECTOR_LEN = array.length;
    return ptr;
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
    cachedFloat64ArrayMemory0 = null;
    cachedUint32ArrayMemory0 = null;
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
        module_or_path = new URL('native_backbone_bg.wasm', import.meta.url);
    }
    const imports = __wbg_get_imports();

    if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
        module_or_path = fetch(module_or_path);
    }

    const { instance, module } = await __wbg_load(await module_or_path, imports);

    return __wbg_finalize_init(instance, module);
}

export { initSync, __wbg_init as default };
