/* tslint:disable */
/* eslint-disable */

/**
 * A decoded `/peerbit/direct-block` message. Response payload bytes are
 * reported as a range into the input frame so the host can alias them
 * without copying.
 */
export class DirectBlockDecodedMessage {
    private constructor();
    free(): void;
    [Symbol.dispose](): void;
    readonly bytes_length: number;
    readonly bytes_offset: number;
    readonly cid: string;
    readonly variant: number;
}

/**
 * Eager-block bookkeeping (`_blockCache` in `RemoteBlocks`). The host keeps
 * the block bytes and drops the buffers named by the returned eviction
 * lists, so bytes never cross the boundary.
 */
export class DirectBlockEagerIndex {
    free(): void;
    [Symbol.dispose](): void;
    /**
     * Track a cid; returns the cids evicted by the insert (ttl/max bound).
     */
    add(cid: string, size: number, now_ms: number): string[];
    clear(): void;
    contains(cid: string): boolean;
    current_bytes(): number;
    del(cid: string): void;
    len(): number;
    constructor(max_entries: number, max_bytes: number, ttl_ms: number);
    /**
     * Evict expired entries and return their cids.
     */
    sweep(now_ms: number): string[];
}

/**
 * Provider-hint cache of `RemoteBlocks` (`rememberProvider`/
 * `rememberProviderHints`/lookup). Timestamps are host-supplied wall-clock
 * milliseconds, as in the other DirectStream cores.
 */
export class DirectBlockProviderCache {
    free(): void;
    [Symbol.dispose](): void;
    clear(): void;
    get(cid: string, now_ms: number): string[] | undefined;
    constructor(me: string, max_entries: number, ttl_ms: number, max_providers_per_cid: number);
    remember_hints(cid: string, providers: string[], now_ms: number): void;
    remember_provider(cid: string, provider: string, now_ms: number): void;
}

/**
 * 4-lane WRR outbound scheduler with byte budget (`pushable-lanes.ts`
 * queue core). The host keeps the byte chunks and maps the returned
 * sequence numbers back to them, so bytes never cross the boundary.
 */
export class DirectStreamLanes {
    free(): void;
    [Symbol.dispose](): void;
    clear(): void;
    is_empty(): boolean;
    lane_bytes(lane: number): number;
    constructor(lanes: number, max_buffered_bytes?: number | null);
    /**
     * Returns the assigned sequence (>= 0), or `-(wouldBeBytes) - 1` when
     * the push would exceed the byte budget (overflow policy 'throw').
     */
    push(lane: number, byte_length: number): number;
    /**
     * Next sequence to emit in WRR order, or -1 when empty.
     */
    shift(): number;
    total_bytes(): number;
}

/**
 * The DirectStream multi-hop routing table (`stream/src/routes.ts` port).
 * All timestamps/sessions are millisecond wall-clock numbers supplied by
 * the host, so behavior under test clocks matches the TS implementation.
 */
export class DirectStreamRoutes {
    free(): void;
    [Symbol.dispose](): void;
    add(from: string, neighbour: string, target: string, distance: number, session: number, remote_session: number, now_ms: number): number;
    cleanup_pending(now_ms: number): void;
    clear(): void;
    count(from: string): number;
    count_all(): number;
    dump_json(): string;
    find_neighbor_json(from: string, target: string): string | undefined;
    get_dependent(peer: string): string[];
    get_fanout_json(from: string, tos: string[], redundancy: number): string | undefined;
    get_prunable(neighbours: string[]): string[];
    get_route_hints_json(from: string, target: string, now_ms: number): string;
    get_route_max_retention_period(): number;
    get_session(remote: string): number | undefined;
    has_pending_cleanup(): boolean;
    has_target(target: string): boolean;
    is_reachable(from: string, target: string, max_distance?: number | null): boolean;
    constructor(me: string, route_max_retention_period_ms?: number | null, max_from_entries?: number | null, max_targets_per_from?: number | null, max_relays_per_target?: number | null);
    remove(target: string): string[];
    remove_neighbour(neighbour: string): void;
    set_route_max_retention_period(ms: number): void;
    update_session(remote: string, session?: number | null): boolean;
}

/**
 * Seen-cache dedup counter (`modifySeenCache` semantics).
 */
export class DirectStreamSeenCache {
    free(): void;
    [Symbol.dispose](): void;
    clear(): void;
    /**
     * `key_kind` 0 = message id (first 33 frame bytes), 1 = sha256 of the
     * whole frame (the ACK path). Returns the seen-before counter.
     */
    modify(frame: Uint8Array, key_kind: number, now_ms: number): number;
    constructor(max: number, ttl_ms: number);
}

/**
 * A decoded `/peerbit/fanout-tree` control frame. One shared shape covers
 * every message kind; the per-kind `ft_decode_*` function documents which
 * fields it populates. Entry lists (tracker reply, provider reply/notify)
 * are flattened into parallel arrays with `entry_addr_counts` delimiting
 * each entry's slice of `entry_addrs`.
 */
export class FanoutTreeDecodedFrame {
    private constructor();
    free(): void;
    [Symbol.dispose](): void;
    readonly ack_token: bigint;
    readonly addrs: Array<any>;
    readonly bid_per_byte: number;
    readonly children: number;
    readonly data_write_drops: number;
    readonly dropped_forwards: number;
    readonly entry_addr_counts: Uint32Array;
    readonly entry_addrs: Array<any>;
    readonly entry_bids: Uint32Array;
    readonly entry_free_slots: Uint32Array;
    readonly entry_hashes: string[];
    readonly entry_levels: Uint32Array;
    readonly event: number;
    readonly flags: number;
    readonly free_slots: number;
    readonly has_ack: boolean;
    readonly has_have_range: boolean;
    readonly has_reply_route: boolean;
    readonly has_text: boolean;
    readonly have_from: number;
    readonly have_to_exclusive: number;
    readonly level: number;
    readonly max_children: number;
    readonly min_free_slots: number;
    readonly missing_seqs: number;
    readonly payload_offset: number;
    readonly reason: number;
    readonly reply_route: string[];
    readonly req_id: number;
    readonly reservation_token: number;
    readonly reserve_root_capacity: boolean;
    readonly route: string[];
    readonly seed: number;
    readonly seqs: Uint32Array;
    readonly text: string;
    readonly ttl_ms: number;
    readonly want: number;
}

/**
 * Stateless Wasm boundary for the canonical journal codec. All u64 values are
 * decimal strings so JavaScript never rounds an LSN, sequence, or fence epoch.
 */
export class NativeDurabilityJournalCodec {
    free(): void;
    [Symbol.dispose](): void;
    encodeFrame(record_lsn: string, tx_sequence: string, writer_epoch: string, writer_owner_id: string, writer_domain_id: string, phase: number, operation_kind: number, program_id: Uint8Array, transaction_id: string, plan_digest: Uint8Array, payload: Uint8Array): Uint8Array;
    constructor();
    scan(bytes: Uint8Array, checkpoint_lsn: string, checkpoint_tx_sequence_highwater: string, expected_program_id: Uint8Array, expected_writer_domain_id: string, checkpoint_writer_epoch: string, checkpoint_writer_owner_id: string | null | undefined, current_writer_epoch: string, current_writer_owner_id: string, retained_transaction_rows: Array<any>): Array<any>;
}

export class NativeEntryV0PlainBuilder {
    free(): void;
    [Symbol.dispose](): void;
    constructor(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array);
}

export class NativeLogBlockStore {
    free(): void;
    [Symbol.dispose](): void;
    clear(): void;
    delete(key: string): boolean;
    delete_many(keys: Array<any>): number;
    entries(): Array<any>;
    get(key: string): Uint8Array | undefined;
    get_many(keys: Array<any>): Array<any>;
    has(key: string): boolean;
    has_many(keys: Array<any>): Array<any>;
    len(): number;
    constructor();
    put(key: string, value: Uint8Array): void;
    put_many(keys: Array<any>, values: Array<any>): void;
    size(): number;
}

export class NativeLogIndex {
    free(): void;
    [Symbol.dispose](): void;
    child_join_entries(hash: string): Array<any>;
    children(hash: string): Array<any>;
    clear(): void;
    count_has_next(next: string, exclude_hash?: string | null): number;
    delete(hash: string): boolean;
    delete_many(hashes: Array<any>): number;
    entry_metadata_batch(hashes: Array<any>): Array<any>;
    entry_metadata_hints_batch(hashes: Array<any>): Array<any>;
    has(hash: string): boolean;
    has_any_head(gids: Array<any>): boolean;
    has_any_head_batch(gid_sets: Array<any>): Array<any>;
    has_head(gid?: string | null): boolean;
    has_many(hashes: Array<any>): Array<any>;
    head_data_entries(gid?: string | null): Array<any>;
    head_entries(gid?: string | null): Array<any>;
    head_join_entries(gid?: string | null): Array<any>;
    heads(gid?: string | null): Array<any>;
    len(): number;
    max_head_data_u32(gid?: string | null): any;
    max_head_data_u32_batch(gids: Array<any>): Array<any>;
    constructor();
    newest_hash(): any;
    oldest_entries(limit: number): Array<any>;
    oldest_hash(): any;
    payload_size_sum(): number;
    plan_delete_recursively(from: Array<any>, skip_first: boolean): Array<any>;
    plan_join(hash: string, next: Array<any>, entry_type: number, reset: boolean, gid?: string | null, wall_time?: bigint | null, logical?: number | null): Array<any>;
    plan_join_batch(hashes: Array<any>, nexts: Array<any>, entry_types: Uint8Array, reset: boolean, gids: Array<any>, wall_times: BigUint64Array, logicals: Uint32Array, cut_check: boolean): Array<any>;
    prepare_entry_v0_plain_chain_and_put(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, wall_times: BigUint64Array, logicals: Uint32Array, gid: string, initial_next: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>): Array<any>;
    prepare_entry_v0_plain_chain_commit_blocks_and_put(block_store: NativeLogBlockStore, clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, wall_times: BigUint64Array, logicals: Uint32Array, gid: string, initial_next: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>): Array<any>;
    prepare_entry_v0_plain_entries_commit_blocks_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, nexts: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>): Array<any>;
    prepare_entry_v0_plain_entries_no_next_commit_blocks_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>): Array<any>;
    prepare_entry_v0_plain_entry_and_put(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_and_put_with_builder(builder: NativeEntryV0PlainBuilder, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_commit_block_and_put(block_store: NativeLogBlockStore, clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_commit_block_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_commit_facts_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_commit_facts_trim_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    prepare_entry_v0_plain_entry_commit_facts_trim_hashes_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    prepare_entry_v0_plain_entry_commit_no_next_facts_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_commit_no_next_facts_trim_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    prepare_entry_v0_plain_entry_commit_no_next_facts_trim_hashes_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    prepare_entry_v0_plain_entry_storage_and_put_with_builder(builder: NativeEntryV0PlainBuilder, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_storage_commit_block_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_storage_commit_block_trim_and_put_with_builder(builder: NativeEntryV0PlainBuilder, block_store: NativeLogBlockStore, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    prepare_entry_v0_plain_entry_storage_facts_and_put_with_builder(builder: NativeEntryV0PlainBuilder, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_entry_v0_plain_entry_storage_facts_trim_and_put_with_builder(builder: NativeEntryV0PlainBuilder, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    prepare_entry_v0_plain_entry_storage_trim_and_put_with_builder(builder: NativeEntryV0PlainBuilder, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    put(hash: string, gid: string, next: Array<any>, entry_type: number, wall_time: bigint, logical: number, payload_size: number, head: boolean, data: any): void;
    put_append_chain(hashes: Array<any>, gid: string, initial_next: Array<any>, entry_type: number, wall_times: BigUint64Array, logicals: Uint32Array, payload_sizes: Uint32Array, datas: Array<any>): void;
    put_many(hashes: Array<any>, gids: Array<any>, nexts: Array<any>, entry_types: Uint8Array, wall_times: BigUint64Array, logicals: Uint32Array, payload_sizes: Uint32Array, heads: Uint8Array, datas: Array<any>): void;
    shadowed_gids(gid: string, next: Array<any>, exclude_hash?: string | null): Array<any>;
    unique_reference_gid_rows_batch(hashes: Array<any>): Array<any>;
    unique_reference_gid_rows_flat_batch(hashes: Array<any>): any;
    unique_reference_gids(hash: string): any;
}

export class NativePeerbitBackbone {
    free(): void;
    [Symbol.dispose](): void;
    add_gid_peers(gid: string, peers: Array<any>, reset: boolean): number;
    append_profile(): Array<any>;
    benchmark_plain_committed_no_next_storage_append_transaction_loop(iterations: number, wall_time_start: bigint, payload_data: Uint8Array, replicas: number, self_hash: string, use_document_index: boolean, document_byte_element_index_limit: number, trim_length_to: any): Array<any>;
    block_delete(key: string): boolean;
    block_delete_many(keys: Array<any>): number;
    block_entries(): Array<any>;
    block_get(key: string): Uint8Array | undefined;
    block_get_many(keys: Array<any>): Array<any>;
    block_has_many(keys: Array<any>): Array<any>;
    block_len(): number;
    block_put(key: string, value: Uint8Array): void;
    block_put_many(keys: Array<any>, values: Array<any>): void;
    block_size(): number;
    clear(): void;
    clear_coordinate_journal(): void;
    clear_coordinate_journal_prefix(byte_len: number, record_count: number): void;
    clear_document_index(): void;
    clear_document_journal(): void;
    clear_document_journal_prefix(byte_len: number, record_count: number): void;
    clear_document_signer_journal(): void;
    clear_document_signer_journal_prefix(byte_len: number, record_count: number): void;
    clear_entry_coordinates(): void;
    clear_entry_known_peers(): void;
    clear_gid_peers(): void;
    clear_prepared_raw_receive_entries(hashes: Array<any>): number;
    clear_shared_log(): void;
    commit_entry_coordinates(hash: string, gid: string, hash_number: string, coordinates: Array<any>, next_hashes: Array<any>, assigned_to_range_boundary: boolean, requested_replicas: number): void;
    commit_entry_coordinates_batch(hashes: Array<any>, gids: Array<any>, hash_numbers: Array<any>, coordinate_batches: Array<any>, next_hash_batches: Array<any>, assigned_to_range_boundaries: Uint8Array, requested_replicas: Array<any>): void;
    commit_entry_coordinates_batch_u64(hashes: Array<any>, gids: Array<any>, hash_numbers: BigUint64Array, coordinate_counts: Uint32Array, coordinates: BigUint64Array, next_hash_batches: Array<any>, assigned_to_range_boundaries: Uint8Array, requested_replicas: Uint32Array): void;
    commit_local_append_for_gid_compact(entry_hash: string, gid: string, entry_hash_number: string, next_hashes: Array<any>, delete_hashes: Array<any>, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    commit_log_blocks_and_graph_batch(hashes: Array<any>, block_bytes: Array<any>, gids: Array<any>, nexts: Array<any>, entry_types: Uint8Array, wall_times: BigUint64Array, logicals: Uint32Array, payload_sizes: Uint32Array, heads: Uint8Array, datas: Array<any>): void;
    commit_log_blocks_graph_and_coordinates_batch(hashes: Array<any>, block_bytes: Array<any>, gids: Array<any>, nexts: Array<any>, entry_types: Uint8Array, wall_times: BigUint64Array, logicals: Uint32Array, payload_sizes: Uint32Array, heads: Uint8Array, datas: Array<any>, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: Array<any>, coordinate_batches: Array<any>, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Array<any>): void;
    commit_prepared_raw_receive_batch(hashes: Array<any>, heads: Uint8Array, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: Array<any>, coordinate_batches: Array<any>, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Array<any>): boolean;
    commit_prepared_raw_receive_batch_u64(hashes: Array<any>, heads: Uint8Array, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: BigUint64Array, coordinate_counts: Uint32Array, coordinates: BigUint64Array, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Uint32Array): boolean;
    commit_prepared_raw_receive_join_batch(hashes: Array<any>, heads: Uint8Array, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: Array<any>, coordinate_batches: Array<any>, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Array<any>): boolean;
    commit_prepared_raw_receive_join_batch_u64(hashes: Array<any>, heads: Uint8Array, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: BigUint64Array, coordinate_counts: Uint32Array, coordinates: BigUint64Array, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Uint32Array): boolean;
    commit_verified_all_prepared_raw_receive_join_batch(hashes: Array<any>, heads: Uint8Array, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: Array<any>, coordinate_batches: Array<any>, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Array<any>): boolean;
    commit_verified_all_prepared_raw_receive_join_batch_u64(hashes: Array<any>, heads: Uint8Array, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: BigUint64Array, coordinate_counts: Uint32Array, coordinates: BigUint64Array, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Uint32Array): boolean;
    commit_verified_prepared_raw_receive_join_batch(hashes: Array<any>, heads: Uint8Array, verify_hashes: Array<any>, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: Array<any>, coordinate_batches: Array<any>, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Array<any>): boolean;
    commit_verified_prepared_raw_receive_join_batch_u64(hashes: Array<any>, heads: Uint8Array, verify_hashes: Array<any>, coordinate_hashes: Array<any>, coordinate_gids: Array<any>, coordinate_hash_numbers: BigUint64Array, coordinate_counts: Uint32Array, coordinates: BigUint64Array, coordinate_next_hash_batches: Array<any>, coordinate_assigned_to_range_boundaries: Uint8Array, coordinate_requested_replicas: Uint32Array): boolean;
    configure_document_schema_ir(schema_ir_bytes: Uint8Array): Array<any>;
    coordinate_index_has_hash(hash: string): boolean;
    coordinate_index_len(): number;
    coordinate_journal(): Uint8Array;
    coordinate_journal_enabled(): boolean;
    coordinate_journal_header(): Uint8Array;
    coordinate_pending_journal_byte_len(): number;
    coordinate_pending_journal_len(): number;
    coordinate_snapshot(): Uint8Array;
    coordinate_value_len(): number;
    count_entry_coordinates_in_ranges(start1: Array<any>, end1: Array<any>, start2: Array<any>, end2: Array<any>, include_assigned_to_range_boundary: boolean): number;
    delete_document(key: string): boolean;
    delete_documents(keys: Array<any>): number;
    delete_documents_result(keys: Array<any>): Uint8Array;
    delete_entry_coordinates(hash: string): boolean;
    delete_entry_coordinates_batch(hashes: Array<any>): void;
    delete_gid_peers(gid: string): boolean;
    delete_range(id: string): boolean;
    document_context(key: string): any;
    document_context_batch(keys: string[]): Array<any>;
    document_context_previous_signature_public_key_batch(keys: string[]): Array<any>;
    document_count(query_bytes: Uint8Array): number;
    document_entry(key: string): any;
    document_exact_string_first_key(field: number, value: string): any;
    document_field_value(key: string, field: number): any;
    document_index_len(): number;
    document_journal(): Uint8Array;
    document_journal_enabled(): boolean;
    document_journal_header(): Uint8Array;
    document_keys_exist(keys: string[]): Uint8Array;
    document_pending_journal_byte_len(): number;
    document_pending_journal_len(): number;
    document_previous_signature_public_key(key: string): Array<any>;
    document_query(query_bytes: Uint8Array, sort_bytes: Uint8Array): Array<any>;
    document_query_page(query_bytes: Uint8Array, sort_bytes: Uint8Array, offset: number, limit: number): Array<any>;
    document_signer_journal(): Uint8Array;
    document_signer_journal_enabled(): boolean;
    document_signer_journal_header(): Uint8Array;
    document_signer_pending_journal_byte_len(): number;
    document_signer_pending_journal_len(): number;
    document_signer_snapshot(): Uint8Array;
    document_snapshot(): Uint8Array;
    document_sum(query_bytes: Uint8Array, field: number): Array<any>;
    document_value_bytes(key: string): any;
    document_value_len(): number;
    /**
     * Serialize one outbound raw exchange sync payload (the full PubSubData
     * nesting) from the native block store. Returns `undefined` when any
     * head's block is not natively stored (the caller falls back to the TS
     * serialization path).
     */
    encode_raw_exchange_sync_payload(topic: string, strict: boolean, hashes: Array<any>, gid_refrences: Array<any>, reserved: Uint8Array): any;
    entry_coordinate_fields(): Array<any>;
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
    graph_child_join_entries(hash: string): Array<any>;
    graph_clear(): void;
    graph_count_has_next(next: string, exclude_hash?: string | null): number;
    graph_delete(hash: string): boolean;
    graph_delete_many(hashes: Array<any>): number;
    graph_entry_metadata_batch(hashes: Array<any>): Array<any>;
    graph_entry_metadata_hints_batch(hashes: Array<any>): Array<any>;
    graph_entry_signature_public_key_batch(hashes: Array<any>): Array<any>;
    graph_has_any_head(gids: Array<any>): boolean;
    graph_has_any_head_batch(gid_sets: Array<any>): Array<any>;
    graph_has_head(gid?: string | null): boolean;
    graph_has_many(hashes: Array<any>): Array<any>;
    graph_head_data_entries(gid?: string | null): Array<any>;
    graph_head_entries(gid?: string | null): Array<any>;
    graph_heads(gid?: string | null): Array<any>;
    graph_join_head_entries(gid?: string | null): Array<any>;
    graph_max_head_data_u32(gid?: string | null): any;
    graph_max_head_data_u32_batch(gids: Array<any>): Array<any>;
    graph_newest_hash(): any;
    graph_oldest_entries(limit: number): Array<any>;
    graph_oldest_hash(): any;
    graph_payload_size_sum(): number;
    graph_plan_delete_recursively(hashes: Array<any>, skip_first: boolean): Array<any>;
    graph_plan_join(hash: string, next: Array<any>, entry_type: number, reset: boolean, gid?: string | null, wall_time?: bigint | null, logical?: number | null): Array<any>;
    graph_plan_join_batch(hashes: Array<any>, nexts: Array<any>, entry_types: Uint8Array, reset: boolean, gids: Array<any>, wall_times: BigUint64Array, logicals: Uint32Array, cut_check: boolean): Array<any>;
    graph_put(hash: string, gid: string, next: Array<any>, entry_type: number, wall_time: bigint, logical: number, payload_size: number, head: boolean, data: any): void;
    graph_put_append_chain(hashes: Array<any>, gid: string, initial_next: Array<any>, entry_type: number, wall_times: BigUint64Array, logicals: Uint32Array, payload_sizes: Uint32Array, datas: Array<any>): void;
    graph_put_batch(hashes: Array<any>, gids: Array<any>, nexts: Array<any>, entry_types: Uint8Array, wall_times: BigUint64Array, logicals: Uint32Array, payload_sizes: Uint32Array, heads: Uint8Array, datas: Array<any>): void;
    graph_shadowed_gids(gid: string, next: Array<any>, exclude_hash?: string | null): Array<any>;
    graph_unique_reference_gid_rows_batch(hashes: Array<any>): Array<any>;
    graph_unique_reference_gid_rows_flat_batch(hashes: Array<any>): any;
    graph_unique_reference_gids(hash: string): any;
    has_block(hash: string): boolean;
    has_log_entry(hash: string): boolean;
    load_coordinate_snapshot_and_journal(snapshot: Uint8Array, journal: Uint8Array): number;
    load_document_signer_snapshot_and_journal(snapshot: Uint8Array, journal: Uint8Array): number;
    load_document_snapshot_and_journal(snapshot: Uint8Array, journal: Uint8Array): number;
    log_len(): number;
    mark_entries_known_by_peer(hashes: Array<any>, peer: string): void;
    constructor(resolution: string, clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array);
    plan_append_for_gid(entry_hash: string, gid: string, entry_hash_number: string, next_hashes: Array<any>, replicas: number, full_replica_candidates: Array<any>, fallback_recipients: Array<any>, delivery_self_hash: string, delivery_enabled: boolean, reliability_ack: boolean, min_acks: any, require_recipients: boolean, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_append_for_gids_batch(entry_hashes: Array<any>, gids: Array<any>, entry_hash_numbers: Array<any>, next_hash_batches: Array<any>, replica_counts: Array<any>, full_replica_candidates: Array<any>, fallback_recipients: Array<any>, delivery_self_hash: string, delivery_enabled: boolean, reliability_ack: boolean, min_acks: any, require_recipients: boolean, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_entry_assignment_for_gid(gid: string, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_entry_leaders_for_gid(gid: string, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_leader_samples_for_gids_batch(gids: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_leaders_for_gids_batch(gids: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_local_append_for_gid_compact(entry_hash: string, gid: string, entry_hash_number: string, next_hashes: Array<any>, replicas: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_prepared_raw_receive_fast_drop(hashes: Array<any>, min_replicas: number, max_replicas: any, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean, _from_hash: string): any;
    plan_prepared_raw_receive_group_assignments(hashes: Array<any>, min_replicas: number, max_replicas: any, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean, from_hash: string): any;
    plan_prepared_raw_receive_group_indexes(hashes: Array<any>, min_replicas: number, max_replicas: any): any;
    plan_prepared_raw_receive_group_leaders(hashes: Array<any>, min_replicas: number, max_replicas: any, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): any;
    plan_prepared_raw_receive_groups(hashes: Array<any>, min_replicas: number, max_replicas: any): any;
    plan_prepared_raw_receive_selection(hashes: Array<any>, min_replicas: number, max_replicas: any, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean, _from_hash: string): any;
    plan_receive_coordinates_for_gids_batch(entry_hashes: Array<any>, gids: Array<any>, entry_hash_numbers: Array<any>, next_hash_batches: Array<any>, replica_counts: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_repair_dispatch_for_entries(entry_hashes: Array<any>, entry_gids: Array<any>, entry_requested_replicas: Array<any>, entry_coordinate_batches: Array<any>, pending_modes: Array<any>, pending_peers_by_mode: Array<any>, optimistic_peers_by_mode: Array<any>, full_replica_repair_candidates: Array<any>, full_replica_repair_candidate_count: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_repair_dispatch_for_resident_entries(pending_modes: Array<any>, pending_peers_by_mode: Array<any>, optimistic_gids_by_mode: Array<any>, optimistic_peers_by_gid_by_mode: Array<any>, full_replica_repair_candidates: Array<any>, full_replica_repair_candidate_count: number, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_request_prune_all_confirmed(hashes: Array<any>, prune_peer: string, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_request_prune_all_confirmed_no_gid_return(hashes: Array<any>, prune_peer: string, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): boolean;
    plan_request_prune_leader_hint_columns(hashes: Array<any>, skip_hashes: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    plan_request_prune_leader_hints(hashes: Array<any>, skip_hashes: Array<any>, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_existing_created: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_ids: Uint32Array, document_projection_encoded_documents: Array<any>, document_projection_signers: Array<any>, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_existing_created: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_ids: Uint32Array, document_projection_signers: Array<any>, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_signer: any, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction_trim(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: number): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_compact_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_value_prefix_bytes: Array<any>, document_existing_created: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_existing_created: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_compact_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_committed_no_next_storage_append_document_index_transaction_trim(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: number): Array<any>;
    prepare_plain_committed_no_next_storage_append_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean): Array<any>;
    prepare_plain_committed_no_next_storage_append_transaction_trim(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, trim_length_to: number): Array<any>;
    prepare_plain_committed_storage_append_document_delete_transaction(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string): Array<any>;
    prepare_plain_committed_storage_append_document_delete_transaction_trim(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, trim_length_to: number): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_keys: Array<any>, document_value_prefix_bytes: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_keys: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_ids: Uint32Array, document_projection_encoded_documents: Array<any>, document_projection_signers: Array<any>, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_ids: Uint32Array, document_projection_encoded_documents: Array<any>, document_projection_signers: Array<any>, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_ids: Uint32Array, document_projection_signers: Array<any>, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_signer: any, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_cached_plan_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_compact_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_value_prefix_bytes: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_compact_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_keys: Array<any>, document_value_prefix_bytes: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, required_previous_signer_public_key: Uint8Array, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_keys: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_ids: Uint32Array, document_projection_encoded_documents: Array<any>, document_projection_signers: Array<any>, required_previous_signer_public_key: Uint8Array, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_compact_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_ids: Uint32Array, document_projection_encoded_documents: Array<any>, document_projection_signers: Array<any>, required_previous_signer_public_key: Uint8Array, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_batch_transaction(wall_times: BigUint64Array, logicals: Uint32Array, fallback_gids: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_keys: Array<any>, document_value_prefix_bytes: Array<any>, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, required_previous_signer_public_key: Uint8Array, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, required_previous_signer_public_key: Uint8Array, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, required_previous_signer_public_key: Uint8Array, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_latest_transaction(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_transaction(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_committed_storage_append_document_index_transaction_trim(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: number): Array<any>;
    prepare_plain_committed_storage_append_transaction(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean): Array<any>;
    prepare_plain_committed_storage_append_transaction_trim(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, trim_length_to: number): Array<any>;
    prepare_plain_entry_commit_facts(wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: any): Array<any>;
    prepare_plain_entry_commit_facts_document_index(wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: any, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_facts_document_index_cached_plan(wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: any, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_latest_facts_document_index_cached_plan_trim_hashes(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: any, document_key: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_latest_facts_document_index_trim_hashes(wall_time: bigint, logical: number, fallback_gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: any, document_key: string, document_value_prefix_bytes: Uint8Array, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_plain_put_payload(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes_plain_put_payload(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_trim_hashes(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number, document_key: string, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan_id: number, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_compact(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_compact_trim_hashes(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_commit_no_next_facts_document_index_trim_hashes(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_entry_storage_facts_and_put(wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;
    prepare_plain_entry_storage_facts_trim_and_put(wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, trim_length_to: number): Array<any>;
    prepare_plain_no_next_storage_append_document_index_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_no_next_storage_append_document_index_transaction_trim(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: number): Array<any>;
    prepare_plain_no_next_storage_append_transaction(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean): Array<any>;
    prepare_plain_no_next_storage_append_transaction_trim(wall_time: bigint, logical: number, gid: string, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, trim_length_to: number): Array<any>;
    prepare_plain_storage_append_document_index_transaction(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any): Array<any>;
    prepare_plain_storage_append_document_index_transaction_trim(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, document_key: string, document_value_prefix_bytes: Uint8Array, document_existing_created: string, document_byte_element_index_limit: number, document_delete_trimmed_heads: boolean, document_projection_plan: any, document_projection_encoded_document: any, document_projection_signer: any, trim_length_to: number): Array<any>;
    prepare_plain_storage_append_transaction(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean): Array<any>;
    prepare_plain_storage_append_transaction_trim(wall_time: bigint, logical: number, gid: string, next_hashes: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, replicas: number, role_age_ms: number, now: string, self_hash: string, self_replicating: boolean, resolve_trimmed_entries: boolean, trim_length_to: number): Array<any>;
    prepare_raw_receive_batch(blocks: Array<any>): Array<any>;
    prepare_raw_receive_columns_batch(blocks: Array<any>): Array<any>;
    prepare_raw_receive_expected_columns_batch(blocks: Array<any>, hashes: Array<any>): Array<any>;
    prepare_raw_receive_expected_compact_columns_batch(blocks: Array<any>, hashes: Array<any>): Array<any>;
    prepare_raw_receive_unverified_columns_batch(blocks: Array<any>): Array<any>;
    prepare_raw_receive_unverified_expected_columns_batch(blocks: Array<any>, hashes: Array<any>): Array<any>;
    prepare_raw_receive_unverified_expected_compact_columns_and_selection_batch(blocks: Array<any>, hashes: Array<any>, min_replicas: number, max_replicas: any, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean, _from_hash: string): any;
    prepare_raw_receive_unverified_expected_compact_columns_batch(blocks: Array<any>, hashes: Array<any>): Array<any>;
    /**
     * Stashed-input twin of
     * `prepare_raw_receive_unverified_expected_compact_columns_and_selection_batch`.
     */
    prepare_stashed_raw_receive_expected_compact_columns_and_selection_batch(session: NativeWireSyncSession, id: Uint8Array, indexes: Uint32Array, hashes: Array<any>, min_replicas: number, max_replicas: any, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean, _from_hash: string): any;
    /**
     * Stashed-input twin of
     * `prepare_raw_receive_unverified_expected_compact_columns_batch`: the
     * blocks come from the wire stash (wasm memory) instead of a JS array.
     */
    prepare_stashed_raw_receive_expected_compact_columns_batch(session: NativeWireSyncSession, id: Uint8Array, indexes: Uint32Array, hashes: Array<any>, verify_signatures: boolean): any;
    project_document_index_simple(encoded_document: Uint8Array, plan: any, created: string, modified: string, head: string, gid: string, size: number, signer: any): Uint8Array;
    put_document_encoded_parts_stored(key: string, value_prefix_bytes: Uint8Array, value_suffix_bytes: Uint8Array, byte_element_index_limit: number): void;
    put_document_encoded_parts_stored_batch(keys: Array<any>, value_prefix_bytes: Array<any>, value_suffix_bytes: Array<any>, byte_element_index_limit: number): void;
    put_entry_coordinates(hash: string, gid: string, hash_number: string, coordinates: Array<any>, assigned_to_range_boundary: boolean, requested_replicas: number): void;
    put_range(id: string, hash: string, timestamp: string, start1: string, end1: string, start2: string, end2: string, width: string, mode: number): void;
    /**
     * Sync fallback for lazily materialized stash-backed heads whose stash
     * entry was already released: serve the raw block bytes from the pending
     * prepared entries or the committed block store.
     */
    raw_receive_block_bytes(hash: string): any;
    register_document_projection_plan(plan: any): number;
    remove_entries_known_by_peer(hashes: Array<any>, peer: string): void;
    remove_gid_peer(peer: string, gid: any): void;
    remove_gid_peers(peer: string, gids: Array<any>): void;
    remove_peer_from_entry_known_peers(peer: string): void;
    reset_append_profile(): void;
    select_prepared_raw_receive_hashes(hashes: Array<any>, min_replicas: number, max_replicas: any, role_age_ms: number, now: string, peer_filter: any, expand_peer_filter: boolean, self_hash: string, include_self: boolean, full_replica_fallback: boolean, include_strict_full_replica: boolean, _from_hash: string): any;
    set_append_profile_enabled(enabled: boolean): void;
    set_coordinate_journal_enabled(enabled: boolean): void;
    set_document_byte_element_index_limit(limit: number): void;
    set_document_context_fields(created: number, modified: number, head: number, gid: number, size: number): void;
    set_document_context_head_field(field: number): void;
    set_document_journal_enabled(enabled: boolean): void;
    set_document_signer_journal_enabled(enabled: boolean): void;
    /**
     * Byte lengths of natively stored entry blocks for `hashes`;
     * `u32::MAX` marks a missing block. Used by the fused send path to plan
     * message chunking without materializing block bytes in JS.
     */
    sync_send_block_byte_lengths(hashes: Array<any>): Uint32Array;
    verify_prepared_raw_receive_entries(hashes: Array<any>): any;
}

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

/**
 * Per-node receive-fusion state: the fused wire decoder for DirectStream and
 * the stash consumed by shared-log programs. See the module docs.
 */
export class NativeWireSyncSession {
    free(): void;
    [Symbol.dispose](): void;
    /**
     * `[stashed, evicted, metaReads, blockCopyOuts, released]`.
     */
    counters(): Uint32Array;
    /**
     * Drop-in replacement for `peerbit_wire`'s `decode_and_verify_batch`
     * (same flat u32 record layout) that additionally stashes raw exchange
     * sync payloads for registered topics, flagging their records with
     * `RECORD_FLAG_SYNC_STASHED`.
     */
    decode_and_verify_batch(frames: Array<any>, now_ms: number): Uint32Array;
    constructor(self_hash: string);
    register_topic(topic: string): void;
    release(id: Uint8Array): boolean;
    stash_len(): number;
    /**
     * Copy head block bytes out to JS (fallback paths only — the fused path
     * hands blocks to `prepare_stashed_raw_receive_*` inside wasm memory).
     */
    stashed_blocks(id: Uint8Array, indexes?: Uint32Array | null): any;
    /**
     * Stash facts for a message id: `[hashes, gidRefrences, byteLengths,
     * reserved, payloadLength]`, or `undefined` when not stashed. Does not
     * consume the entry, but pins it: a resolved message has no TS decode
     * fallback anymore, so the entry must survive FIFO eviction until
     * `release` is called when processing finishes.
     */
    stashed_meta(id: Uint8Array): any;
    topic_count(): number;
    unregister_topic(topic: string): boolean;
}

/**
 * A decoded `/peerbit/topic-control-plane` message. `Data` payload bytes are
 * reported as a range into the input frame so the host can alias them
 * without copying. `topics` doubles as the candidate list for the
 * `TopicRootCandidates` variant; `text` carries the public-key hash
 * (`PeerUnavailable`) or the topic (`TopicRootQuery`/`Response`).
 */
export class TopicControlDecodedMessage {
    private constructor();
    free(): void;
    [Symbol.dispose](): void;
    readonly data_length: number;
    readonly data_offset: number;
    /**
     * `strict` (PubSubData) or `requestSubscribers` (Subscribe).
     */
    readonly flag: boolean;
    readonly request_id: number;
    readonly root: string | undefined;
    readonly session: bigint;
    readonly text: string;
    readonly timestamp: bigint;
    readonly topics: string[];
    readonly variant: number;
}

/**
 * `TopicRootDirectory` root-resolution state (explicit roots + normalized
 * deterministic candidates). Trackers and the resolver callback stay
 * host-side.
 */
export class TopicControlRootDirectory {
    free(): void;
    [Symbol.dispose](): void;
    delete_root(topic: string): void;
    get_default_candidates(): string[];
    get_root(topic: string): string | undefined;
    constructor();
    resolve_deterministic_candidate(topic: string): string | undefined;
    set_default_candidates(candidates: string[]): void;
    set_root(topic: string, root: string): void;
}

export function benchmark_entry_v0_storage_verify_modes(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, iterations: number, payload_data: Uint8Array): Array<any>;

export function benchmark_plain_entry_v0_core(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, iterations: number, payload_data: Uint8Array): Array<any>;

export function benchmark_plain_entry_v0_crypto(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, iterations: number, payload_data: Uint8Array): Array<any>;

export function benchmark_plain_entry_v0_digest_key_core(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, iterations: number, payload_data: Uint8Array): Array<any>;

/**
 * Serialize a `/peerbit/direct-block` `BlockResponse` payload for a block
 * held in the native store. The stored bytes are copied straight into the
 * borsh payload (codec owned by `peerbit_wire::block_exchange`), so serving
 * a natively stored block never materializes the block bytes as a JS value.
 */
export function block_response_payload(store: NativeLogBlockStore, cid: string): Uint8Array | undefined;

export function calculate_raw_cid_v1(bytes: Uint8Array): string;

export function calculate_raw_cid_v1_batch(blocks: Array<any>): Array<any>;

/**
 * Decode a borsh `BlockMessage` payload (`BlockRequest(0)`/`BlockResponse(1)`).
 */
export function db_decode_block_message(frame: Uint8Array): DirectBlockDecodedMessage;

export function db_default_provider_candidates(negotiated: string[], connected: string[], me: string): string[];

export function db_encode_block_request(cid: string): Uint8Array;

export function db_encode_block_response(cid: string, bytes: Uint8Array): Uint8Array;

export function db_normalize_provider_hints(providers: string[], me: string, limit: number): string[];

export function db_pick_request_batch(providers: string[], me: string, attempt: number): string[];

/**
 * Decode a batch of direct-stream frames and verify their signatures
 * (sha256-prehashed Ed25519, batched via ed25519-dalek). Returns
 * [`RECORD_WORDS`] u32 words per input frame; see the layout above.
 *
 * `now_ms` is the wall clock used for the header expiry check.
 */
export function decode_and_verify_batch(frames: Array<any>, now_ms: number): Uint32Array;

/**
 * Decode a frame into the stable debug-JSON shape used by the parity tests.
 */
export function decode_frame_to_json(frame: Uint8Array): string;

/**
 * Returns `[myIndexAsString, nextHop?]`: the first element is our index in
 * the trace ("-1" when absent), the second — present only when there is a
 * previous hop — is the peer to relay the ACK back to.
 */
export function ds_ack_next_hop(trace: string[], me: string): string[];

export function ds_filter_flood_targets(candidates: string[], from: string, signed: string[], hops: string[]): Uint32Array;

export function ds_filter_silent_relay_recipients(recipients: string[], me: string, from: string, connected: string[], hops: string[]): string[];

/**
 * Returns `[from, neighbour]` — the route edge to learn from an ACK.
 */
export function ds_seek_ack_route_update(current: string, upstream: string | null | undefined, downstream: string): string[];

export function ds_select_redundancy_probes(peers: string[], used: string[], redundancy: number): string[];

export function ds_should_acknowledge(is_recipient: boolean, seen_before: number, redundancy: number): boolean;

export function ds_should_ignore_data(seen_before: number, acknowledged_mode: boolean, redundancy: number, hops: string[], me: string, signed_by_self: boolean): boolean;

export function encode_entry_v0_signable(clock_id: Uint8Array, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Uint8Array;

export function encode_entry_v0_signable_batch(clock_ids: Array<any>, wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, nexts: Array<any>, entry_types: Uint8Array, meta_datas: Array<any>, payload_datas: Array<any>): Array<any>;

export function encode_entry_v0_storage(clock_id: Uint8Array, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, signature: Uint8Array, signature_public_key: Uint8Array, prehash: number): Uint8Array;

export function encode_entry_v0_storage_batch_with_cids(clock_ids: Array<any>, wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, nexts: Array<any>, entry_types: Uint8Array, meta_datas: Array<any>, payload_datas: Array<any>, signatures: Array<any>, signature_public_keys: Array<any>, prehashes: Uint8Array): Array<any>;

export function encode_entry_v0_storage_with_cid(clock_id: Uint8Array, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array, signature: Uint8Array, signature_public_key: Uint8Array, prehash: number): Array<any>;

export function entry_v0_plain_payload_data_from_storage(bytes: Uint8Array): Uint8Array;

export function ft_decode_end(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_ihave(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_join_accept(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_join_reject(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_join_req(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_join_response_req_id(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_parent_probe_reply(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_parent_probe_req(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_provider_announce(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_provider_notify(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_provider_query(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_provider_reply(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_provider_subscribe(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_repair_seqs(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_route_query(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_route_reply(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_tracker_announce(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_tracker_feedback(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_tracker_query(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_tracker_reply(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_unicast(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_decode_unicast_ack(data: Uint8Array): FanoutTreeDecodedFrame | undefined;

export function ft_encode_data(payload: Uint8Array): Uint8Array;

export function ft_encode_end(channel_key: Uint8Array, last_seq_exclusive: number): Uint8Array;

export function ft_encode_fetch_req(channel_key: Uint8Array, req_id: number, missing_seqs: Float64Array): Uint8Array;

export function ft_encode_ihave(channel_key: Uint8Array, have_from: number, have_to_exclusive: number): Uint8Array;

export function ft_encode_join_accept(channel_key: Uint8Array, req_id: number, level: number, parent_route_from_root: string[], has_have_range: boolean, have_from: number, have_to_exclusive: number): Uint8Array;

export function ft_encode_join_reject(channel_key: Uint8Array, req_id: number, reason: number, redirect_hashes: string[], redirect_addr_counts: Uint32Array, redirect_addrs: Array<any>): Uint8Array;

export function ft_encode_join_req(channel_key: Uint8Array, req_id: number, bid_per_byte: number, parent_upgrade_reservation_token: number): Uint8Array;

export function ft_encode_kick(channel_key: Uint8Array): Uint8Array;

export function ft_encode_leave(channel_key: Uint8Array): Uint8Array;

export function ft_encode_parent_probe_reply(channel_key: Uint8Array, req_id: number, flags: number, level: number, max_children: number, free_slots: number, children: number, have_to_exclusive: number, missing_seqs: number, data_write_drops: number, dropped_forwards: number, reservation_token: number): Uint8Array;

export function ft_encode_parent_probe_req(channel_key: Uint8Array, req_id: number, min_free_slots: number, reserve_root_capacity: boolean): Uint8Array;

export function ft_encode_provider_announce(namespace_key: Uint8Array, ttl_ms: number, addrs: Array<any>): Uint8Array;

export function ft_encode_provider_notify(namespace_key: Uint8Array, entry_hashes: string[], entry_addr_counts: Uint32Array, entry_addrs: Array<any>): Uint8Array;

export function ft_encode_provider_query(namespace_key: Uint8Array, req_id: number, want: number, seed: number): Uint8Array;

export function ft_encode_provider_reply(namespace_key: Uint8Array, req_id: number, entry_hashes: string[], entry_addr_counts: Uint32Array, entry_addrs: Array<any>): Uint8Array;

export function ft_encode_provider_subscribe(namespace_key: Uint8Array, want: number, ttl_ms: number): Uint8Array;

export function ft_encode_provider_unsubscribe(namespace_key: Uint8Array): Uint8Array;

export function ft_encode_publish_proxy(channel_key: Uint8Array, payload: Uint8Array): Uint8Array;

export function ft_encode_repair_req(channel_key: Uint8Array, req_id: number, missing_seqs: Float64Array): Uint8Array;

export function ft_encode_route_query(channel_key: Uint8Array, req_id: number, target_hash: string): Uint8Array;

export function ft_encode_route_reply(channel_key: Uint8Array, req_id: number, route: string[]): Uint8Array;

export function ft_encode_tracker_announce(channel_key: Uint8Array, ttl_ms: number, level: number, max_children: number, free_slots: number, bid_per_byte: number, addrs: Array<any>): Uint8Array;

export function ft_encode_tracker_feedback(channel_key: Uint8Array, candidate_hash: string, event: number, reason: number): Uint8Array;

export function ft_encode_tracker_query(channel_key: Uint8Array, req_id: number, want: number): Uint8Array;

export function ft_encode_tracker_reply(channel_key: Uint8Array, req_id: number, entry_hashes: string[], entry_levels: Float64Array, entry_free_slots: Float64Array, entry_bids: Float64Array, entry_addr_counts: Uint32Array, entry_addrs: Array<any>): Uint8Array;

export function ft_encode_unicast(channel_key: Uint8Array, route: string[], payload: Uint8Array, has_ack: boolean, ack_token: bigint, reply_route: string[]): Uint8Array;

export function ft_encode_unicast_ack(channel_key: Uint8Array, ack_token: bigint, route: string[]): Uint8Array;

/**
 * `evaluateParentUpgradeGate`; returns the skip-reason code in the low
 * byte (0 = run) plus the retry-after-seq reset flag (0x100).
 */
export function ft_pu_evaluate_gate(children_size: number, missing_seqs_size: number, last_repair_sent_at: number, end_seq_exclusive: number, parent_upgrade_retry_after_seq: number, max_seq_seen: number, parent_upgrade_count: number, parent_upgrade_backoff_until: number, parent_upgrade_last_at: number, last_parent_data_at: number, last_parent_upgrade_activity_at: number, leaf_only: boolean, repair_guard: boolean, data_guard: boolean, ended_and_complete: boolean, max_per_peer: number, cooldown_ms: number, quiet_ms: number, repair_quiet_ms: number, now: number): number;

/**
 * `normalizeParentUpgradePolicy` over the fixed-order f64 protocol
 * documented in `fanout_tree.rs` (numeric options gated by the presence
 * bitmask at index 30 so an explicit NaN flows through like TS, -1/0/1
 * tri-state booleans, mode 0 unset / 1 direct / 2 probe / 3 shadow).
 */
export function ft_pu_normalize_policy(options: Float64Array): Float64Array;

export function prepare_entry_v0_plain_chain(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, wall_times: BigUint64Array, logicals: Uint32Array, gid: string, initial_next: Array<any>, entry_type: number, meta_datas: Array<any>, payload_datas: Array<any>): Array<any>;

export function prepare_entry_v0_plain_entry(clock_id: Uint8Array, private_key: Uint8Array, public_key: Uint8Array, wall_time: bigint, logical: number, gid: string, next: Array<any>, entry_type: number, meta_data: any, payload_data: Uint8Array): Array<any>;

export function prepare_raw_entry_v0_batch(blocks: Array<any>): Array<any>;

/**
 * Decode a frame and re-encode it from the parsed representation. Used by
 * the golden-vector parity tests to prove Rust encoding is byte-identical
 * to the TS wire format.
 */
export function reencode_frame(frame: Uint8Array): Uint8Array;

export function sign_ed25519(private_key: Uint8Array, public_key: Uint8Array, data: Uint8Array): Uint8Array;

/**
 * The signable byte range of a frame: the serialized message with the
 * delivery mode and signatures excluded (both are mutated in transit).
 * Must match `Message.getSignableBytes()` in the TS implementation.
 */
export function signable_bytes(frame: Uint8Array): Uint8Array;

/**
 * Decode a borsh `PubSubMessage` payload (variants 0-7).
 */
export function tc_decode_pubsub_message(frame: Uint8Array): TopicControlDecodedMessage;

export function tc_encode_get_subscribers(topics: string[]): Uint8Array;

export function tc_encode_peer_unavailable(public_key_hash: string, session: bigint, timestamp: bigint, topics: string[]): Uint8Array;

export function tc_encode_pubsub_data(topics: string[], strict: boolean, data: Uint8Array): Uint8Array;

export function tc_encode_subscribe(topics: string[], request_subscribers: boolean): Uint8Array;

export function tc_encode_topic_root_candidates(candidates: string[]): Uint8Array;

export function tc_encode_topic_root_query(request_id: number, topic: string): Uint8Array;

export function tc_encode_topic_root_query_response(request_id: number, topic: string, root?: string | null): Uint8Array;

export function tc_encode_unsubscribe(topics: string[]): Uint8Array;

export function tc_normalize_auto_candidates(candidates: string[], me: string): string[];

export function tc_shard_topic(topic: string, shard_count: number, prefix: string): string;

export function tc_subscribe_should_replace(existing_session: bigint | null | undefined, session: bigint): boolean;

/**
 * `lasts` carries interleaved (session, timestamp) watermark pairs for the
 * relevant topics that have one; see `subscription_is_latest`.
 */
export function tc_subscription_is_latest(lasts: BigUint64Array, session: bigint, timestamp: bigint): boolean;

export function tc_topic_hash32(topic: string): number;

/**
 * Deterministic Rust-authored golden vectors for the reverse parity
 * direction (Rust encode → TS decode). See `wire::build_test_corpus`.
 */
export function test_corpus_frames(): Array<any>;

export function verify_ed25519_batch(signatures: Array<any>, public_keys: Array<any>, messages: Array<any>): Uint8Array;

export function verify_entry_v0_ed25519_batch(clock_ids: Array<any>, wall_times: BigUint64Array, logicals: Uint32Array, gids: Array<any>, nexts: Array<any>, entry_types: Uint8Array, meta_datas: Array<any>, payload_datas: Array<any>, signatures: Array<any>, public_keys: Array<any>): Uint8Array;

export function verify_entry_v0_ed25519_storage_batch(blocks: Array<any>): Uint8Array;

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
    readonly memory: WebAssembly.Memory;
    readonly __wbg_nativepeerbitbackbone_free: (a: number, b: number) => void;
    readonly nativepeerbitbackbone_append_profile: (a: number) => any;
    readonly nativepeerbitbackbone_block_len: (a: number) => number;
    readonly nativepeerbitbackbone_clear: (a: number) => void;
    readonly nativepeerbitbackbone_has_block: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_has_log_entry: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_log_len: (a: number) => number;
    readonly nativepeerbitbackbone_new: (a: number, b: number, c: any, d: any, e: any) => [number, number, number];
    readonly nativepeerbitbackbone_reset_append_profile: (a: number) => void;
    readonly nativepeerbitbackbone_set_append_profile_enabled: (a: number, b: number) => void;
    readonly __wbg_nativedurabilityjournalcodec_free: (a: number, b: number) => void;
    readonly nativedurabilityjournalcodec_encodeFrame: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: number, n: any, o: number, p: number, q: any, r: any) => [number, number, number, number];
    readonly nativedurabilityjournalcodec_scan: (a: number, b: any, c: number, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: any) => [number, number, number];
    readonly nativedurabilityjournalcodec_new: () => number;
    readonly nativepeerbitbackbone_add_gid_peers: (a: number, b: number, c: number, d: any, e: number) => [number, number, number];
    readonly nativepeerbitbackbone_clear_entry_coordinates: (a: number) => void;
    readonly nativepeerbitbackbone_clear_entry_known_peers: (a: number) => void;
    readonly nativepeerbitbackbone_clear_gid_peers: (a: number) => void;
    readonly nativepeerbitbackbone_clear_shared_log: (a: number) => void;
    readonly nativepeerbitbackbone_commit_entry_coordinates: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: any, j: number, k: number) => [number, number];
    readonly nativepeerbitbackbone_commit_entry_coordinates_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any) => [number, number];
    readonly nativepeerbitbackbone_commit_entry_coordinates_batch_u64: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any) => [number, number];
    readonly nativepeerbitbackbone_commit_local_append_for_gid_compact: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: any, o: number, p: number, q: number, r: number, s: number, t: number) => [number, number, number];
    readonly nativepeerbitbackbone_count_entry_coordinates_in_ranges: (a: number, b: any, c: any, d: any, e: any, f: number) => [number, number, number];
    readonly nativepeerbitbackbone_delete_entry_coordinates: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_delete_entry_coordinates_batch: (a: number, b: any) => [number, number];
    readonly nativepeerbitbackbone_delete_gid_peers: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_delete_range: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_entry_coordinate_fields: (a: number) => [number, number, number];
    readonly nativepeerbitbackbone_entry_coordinate_hashes: (a: number) => any;
    readonly nativepeerbitbackbone_entry_hash_numbers_in_range: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number) => [number, number, number];
    readonly nativepeerbitbackbone_entry_hash_numbers_in_range_u64: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number) => [number, number, number];
    readonly nativepeerbitbackbone_entry_hashes_for_hash_numbers: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_entry_hashes_for_hash_numbers_flat_u64: (a: number, b: any) => any;
    readonly nativepeerbitbackbone_entry_hashes_for_hash_numbers_u64: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_find_leaders: (a: number, b: any, c: number, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativepeerbitbackbone_find_leaders_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativepeerbitbackbone_get_entry_coordinates: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_get_gid_coordinates: (a: number, b: number, c: number, d: number) => any;
    readonly nativepeerbitbackbone_get_grid: (a: number, b: number, c: number, d: number) => [number, number, number];
    readonly nativepeerbitbackbone_mark_entries_known_by_peer: (a: number, b: any, c: number, d: number) => [number, number];
    readonly nativepeerbitbackbone_plan_append_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: any, k: any, l: number, m: number, n: number, o: number, p: any, q: number, r: number, s: number, t: number, u: any, v: number, w: number, x: number, y: number, z: number, a1: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_append_for_gids_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: number, j: number, k: number, l: number, m: any, n: number, o: number, p: number, q: number, r: any, s: number, t: number, u: number, v: number, w: number, x: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_entry_assignment_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_entry_leaders_for_gid: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_leader_samples_for_gids_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_leaders_for_gids_batch: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_local_append_for_gid_compact: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: any, n: number, o: number, p: number, q: number, r: number, s: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_receive_coordinates_for_gids_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: number, h: number, i: number, j: any, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_repair_dispatch_for_entries: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: number, k: number, l: number, m: number, n: any, o: number, p: number, q: number, r: number, s: number, t: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_repair_dispatch_for_resident_entries: (a: number, b: any, c: any, d: any, e: any, f: any, g: number, h: number, i: number, j: number, k: any, l: number, m: number, n: number, o: number, p: number, q: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_request_prune_all_confirmed: (a: number, b: any, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_request_prune_all_confirmed_no_gid_return: (a: number, b: any, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_request_prune_leader_hint_columns: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_request_prune_leader_hints: (a: number, b: any, c: any, d: number, e: number, f: number, g: any, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number, number];
    readonly nativepeerbitbackbone_put_entry_coordinates: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any, i: number, j: number) => [number, number];
    readonly nativepeerbitbackbone_put_range: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number) => [number, number];
    readonly nativepeerbitbackbone_remove_entries_known_by_peer: (a: number, b: any, c: number, d: number) => [number, number];
    readonly nativepeerbitbackbone_remove_gid_peer: (a: number, b: number, c: number, d: any) => [number, number];
    readonly nativepeerbitbackbone_remove_gid_peers: (a: number, b: number, c: number, d: any) => [number, number];
    readonly nativepeerbitbackbone_remove_peer_from_entry_known_peers: (a: number, b: number, c: number) => void;
    readonly nativepeerbitbackbone_clear_document_index: (a: number) => void;
    readonly nativepeerbitbackbone_clear_document_journal: (a: number) => void;
    readonly nativepeerbitbackbone_clear_document_journal_prefix: (a: number, b: number, c: number) => void;
    readonly nativepeerbitbackbone_clear_document_signer_journal: (a: number) => void;
    readonly nativepeerbitbackbone_clear_document_signer_journal_prefix: (a: number, b: number, c: number) => void;
    readonly nativepeerbitbackbone_configure_document_schema_ir: (a: number, b: number, c: number) => [number, number, number];
    readonly nativepeerbitbackbone_delete_document: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_delete_documents: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_delete_documents_result: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_document_context: (a: number, b: number, c: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_context_batch: (a: number, b: number, c: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_context_previous_signature_public_key_batch: (a: number, b: number, c: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_count: (a: number, b: number, c: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_entry: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_document_exact_string_first_key: (a: number, b: number, c: number, d: number) => any;
    readonly nativepeerbitbackbone_document_field_value: (a: number, b: number, c: number, d: number) => any;
    readonly nativepeerbitbackbone_document_index_len: (a: number) => number;
    readonly nativepeerbitbackbone_document_journal: (a: number) => [number, number];
    readonly nativepeerbitbackbone_document_journal_enabled: (a: number) => number;
    readonly nativepeerbitbackbone_document_journal_header: (a: number) => [number, number];
    readonly nativepeerbitbackbone_document_keys_exist: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_document_pending_journal_byte_len: (a: number) => number;
    readonly nativepeerbitbackbone_document_pending_journal_len: (a: number) => number;
    readonly nativepeerbitbackbone_document_previous_signature_public_key: (a: number, b: number, c: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_query: (a: number, b: number, c: number, d: number, e: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_query_page: (a: number, b: number, c: number, d: number, e: number, f: number, g: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_signer_journal: (a: number) => [number, number];
    readonly nativepeerbitbackbone_document_signer_journal_enabled: (a: number) => number;
    readonly nativepeerbitbackbone_document_signer_pending_journal_byte_len: (a: number) => number;
    readonly nativepeerbitbackbone_document_signer_pending_journal_len: (a: number) => number;
    readonly nativepeerbitbackbone_document_signer_snapshot: (a: number) => [number, number];
    readonly nativepeerbitbackbone_document_snapshot: (a: number) => [number, number];
    readonly nativepeerbitbackbone_document_sum: (a: number, b: number, c: number, d: number) => [number, number, number];
    readonly nativepeerbitbackbone_document_value_bytes: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_document_value_len: (a: number) => number;
    readonly nativepeerbitbackbone_load_document_signer_snapshot_and_journal: (a: number, b: any, c: any) => [number, number, number];
    readonly nativepeerbitbackbone_load_document_snapshot_and_journal: (a: number, b: any, c: any) => [number, number, number];
    readonly nativepeerbitbackbone_project_document_index_simple: (a: number, b: any, c: any, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: any) => [number, number, number];
    readonly nativepeerbitbackbone_put_document_encoded_parts_stored: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number) => [number, number];
    readonly nativepeerbitbackbone_put_document_encoded_parts_stored_batch: (a: number, b: any, c: any, d: any, e: number) => [number, number];
    readonly nativepeerbitbackbone_register_document_projection_plan: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_set_document_byte_element_index_limit: (a: number, b: number) => [number, number];
    readonly nativepeerbitbackbone_set_document_context_fields: (a: number, b: number, c: number, d: number, e: number, f: number) => void;
    readonly nativepeerbitbackbone_set_document_context_head_field: (a: number, b: number) => void;
    readonly nativepeerbitbackbone_set_document_journal_enabled: (a: number, b: number) => void;
    readonly nativepeerbitbackbone_set_document_signer_journal_enabled: (a: number, b: number) => void;
    readonly nativepeerbitbackbone_document_signer_journal_header: (a: number) => [number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_delete_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_delete_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: any, q: any, r: number, s: number, t: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: any, q: number, r: number, s: any, t: any, u: any, v: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: number, q: number, r: any, s: any, t: any, u: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: number, q: number, r: any, s: any, t: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_plain_put_payload_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: any, v: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_compact_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: any, v: any, w: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_cached_plan_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: any, w: any, x: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: any, q: number, r: number, s: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: number, q: number, r: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_plain_put_payload_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_compact_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: any, w: any, x: any, y: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: any, q: any, r: number, s: number, t: any, u: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: any, q: number, r: number, s: any, t: any, u: any, v: any, w: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_cached_plan_compact_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: number, q: number, r: any, s: any, t: any, u: any, v: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: any, q: number, r: number, s: any, t: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_compact_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: any, w: any, x: any, y: any, z: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_required_previous_signer_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: any, x: any, y: any, z: any, a1: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_latest_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: any, x: any, y: any, z: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: number, z: any, a1: any, b1: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_document_index_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: number, z: any, a1: any, b1: any, c1: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_storage_append_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number) => [number, number, number];
    readonly nativepeerbitbackbone_clear_coordinate_journal: (a: number) => void;
    readonly nativepeerbitbackbone_clear_coordinate_journal_prefix: (a: number, b: number, c: number) => void;
    readonly nativepeerbitbackbone_coordinate_index_has_hash: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_coordinate_index_len: (a: number) => number;
    readonly nativepeerbitbackbone_coordinate_journal: (a: number) => [number, number];
    readonly nativepeerbitbackbone_coordinate_journal_enabled: (a: number) => number;
    readonly nativepeerbitbackbone_coordinate_journal_header: (a: number) => [number, number];
    readonly nativepeerbitbackbone_coordinate_pending_journal_byte_len: (a: number) => number;
    readonly nativepeerbitbackbone_coordinate_pending_journal_len: (a: number) => number;
    readonly nativepeerbitbackbone_coordinate_snapshot: (a: number) => [number, number];
    readonly nativepeerbitbackbone_coordinate_value_len: (a: number) => number;
    readonly nativepeerbitbackbone_load_coordinate_snapshot_and_journal: (a: number, b: any, c: any) => [number, number, number];
    readonly nativepeerbitbackbone_set_coordinate_journal_enabled: (a: number, b: number) => void;
    readonly nativepeerbitbackbone_clear_prepared_raw_receive_entries: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_prepared_raw_receive_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_prepared_raw_receive_batch_u64: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_prepared_raw_receive_join_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_prepared_raw_receive_join_batch_u64: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_verified_all_prepared_raw_receive_join_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_verified_all_prepared_raw_receive_join_batch_u64: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_verified_prepared_raw_receive_join_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any) => [number, number, number];
    readonly nativepeerbitbackbone_commit_verified_prepared_raw_receive_join_batch_u64: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any, l: any) => [number, number, number];
    readonly nativepeerbitbackbone_plan_prepared_raw_receive_fast_drop: (a: number, b: any, c: number, d: any, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_prepared_raw_receive_group_assignments: (a: number, b: any, c: number, d: any, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_prepared_raw_receive_group_indexes: (a: number, b: any, c: number, d: any) => [number, number, number];
    readonly nativepeerbitbackbone_plan_prepared_raw_receive_group_leaders: (a: number, b: any, c: number, d: any, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number) => [number, number, number];
    readonly nativepeerbitbackbone_plan_prepared_raw_receive_groups: (a: number, b: any, c: number, d: any) => [number, number, number];
    readonly nativepeerbitbackbone_plan_prepared_raw_receive_selection: (a: number, b: any, c: number, d: any, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_columns_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_expected_columns_batch: (a: number, b: any, c: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_expected_compact_columns_batch: (a: number, b: any, c: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_unverified_columns_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_unverified_expected_columns_batch: (a: number, b: any, c: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_unverified_expected_compact_columns_and_selection_batch: (a: number, b: any, c: any, d: number, e: any, f: number, g: number, h: number, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_raw_receive_unverified_expected_compact_columns_batch: (a: number, b: any, c: any) => [number, number, number];
    readonly nativepeerbitbackbone_select_prepared_raw_receive_hashes: (a: number, b: any, c: number, d: any, e: number, f: number, g: number, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativepeerbitbackbone_verify_prepared_raw_receive_entries: (a: number, b: any) => [number, number, number];
    readonly __wbg_nativewiresyncsession_free: (a: number, b: number) => void;
    readonly nativepeerbitbackbone_prepare_stashed_raw_receive_expected_compact_columns_and_selection_batch: (a: number, b: number, c: number, d: number, e: any, f: any, g: number, h: any, i: number, j: number, k: number, l: any, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_stashed_raw_receive_expected_compact_columns_batch: (a: number, b: number, c: number, d: number, e: any, f: any, g: number) => [number, number, number];
    readonly nativepeerbitbackbone_raw_receive_block_bytes: (a: number, b: number, c: number) => any;
    readonly nativewiresyncsession_counters: (a: number) => [number, number];
    readonly nativewiresyncsession_decode_and_verify_batch: (a: number, b: any, c: number) => [number, number];
    readonly nativewiresyncsession_new: (a: number, b: number) => number;
    readonly nativewiresyncsession_register_topic: (a: number, b: number, c: number) => void;
    readonly nativewiresyncsession_release: (a: number, b: number, c: number) => number;
    readonly nativewiresyncsession_stash_len: (a: number) => number;
    readonly nativewiresyncsession_stashed_blocks: (a: number, b: number, c: number, d: number) => any;
    readonly nativewiresyncsession_stashed_meta: (a: number, b: number, c: number) => any;
    readonly nativewiresyncsession_topic_count: (a: number) => number;
    readonly nativewiresyncsession_unregister_topic: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_block_delete: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_block_delete_many: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_block_entries: (a: number) => any;
    readonly nativepeerbitbackbone_block_get: (a: number, b: number, c: number) => [number, number];
    readonly nativepeerbitbackbone_block_get_many: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_block_has_many: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_block_put: (a: number, b: number, c: number, d: number, e: number) => void;
    readonly nativepeerbitbackbone_block_put_many: (a: number, b: any, c: any) => [number, number];
    readonly nativepeerbitbackbone_block_size: (a: number) => number;
    readonly nativepeerbitbackbone_commit_log_blocks_and_graph_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any) => [number, number];
    readonly nativepeerbitbackbone_commit_log_blocks_graph_and_coordinates_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any, l: any, m: any, n: any, o: any, p: any, q: any, r: any) => [number, number];
    readonly nativepeerbitbackbone_graph_child_join_entries: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_graph_clear: (a: number) => void;
    readonly nativepeerbitbackbone_graph_count_has_next: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly nativepeerbitbackbone_graph_delete: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_graph_delete_many: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_entry_metadata_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_entry_metadata_hints_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_entry_signature_public_key_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_has_any_head: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_has_any_head_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_has_head: (a: number, b: number, c: number) => number;
    readonly nativepeerbitbackbone_graph_has_many: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_head_data_entries: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_graph_head_entries: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_graph_heads: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_graph_join_head_entries: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_graph_max_head_data_u32: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_graph_max_head_data_u32_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_newest_hash: (a: number) => any;
    readonly nativepeerbitbackbone_graph_oldest_entries: (a: number, b: number) => any;
    readonly nativepeerbitbackbone_graph_oldest_hash: (a: number) => any;
    readonly nativepeerbitbackbone_graph_payload_size_sum: (a: number) => number;
    readonly nativepeerbitbackbone_graph_plan_delete_recursively: (a: number, b: any, c: number) => [number, number, number];
    readonly nativepeerbitbackbone_graph_plan_join: (a: number, b: number, c: number, d: any, e: number, f: number, g: number, h: number, i: number, j: bigint, k: number) => [number, number, number];
    readonly nativepeerbitbackbone_graph_plan_join_batch: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: any, i: number) => [number, number, number];
    readonly nativepeerbitbackbone_graph_put: (a: number, b: number, c: number, d: number, e: number, f: any, g: number, h: bigint, i: number, j: number, k: number, l: any) => [number, number];
    readonly nativepeerbitbackbone_graph_put_append_chain: (a: number, b: any, c: number, d: number, e: any, f: number, g: any, h: any, i: any, j: any) => [number, number];
    readonly nativepeerbitbackbone_graph_put_batch: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any) => [number, number];
    readonly nativepeerbitbackbone_graph_shadowed_gids: (a: number, b: number, c: number, d: any, e: number, f: number) => [number, number, number];
    readonly nativepeerbitbackbone_graph_unique_reference_gid_rows_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_unique_reference_gid_rows_flat_batch: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_graph_unique_reference_gids: (a: number, b: number, c: number) => any;
    readonly nativepeerbitbackbone_encode_raw_exchange_sync_payload: (a: number, b: number, c: number, d: number, e: any, f: any, g: number, h: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_storage_facts_and_put: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_storage_facts_trim_and_put: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_no_next_storage_append_document_index_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: any, z: any, a1: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_no_next_storage_append_document_index_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: any, z: any, a1: any, b1: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_no_next_storage_append_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_no_next_storage_append_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_storage_append_document_index_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: number, z: any, a1: any, b1: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_storage_append_document_index_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: number, z: any, a1: any, b1: any, c1: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_storage_append_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_storage_append_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number) => [number, number, number];
    readonly nativepeerbitbackbone_sync_send_block_byte_lengths: (a: number, b: any) => [number, number, number];
    readonly nativepeerbitbackbone_benchmark_plain_committed_no_next_storage_append_transaction_loop: (a: number, b: number, c: bigint, d: any, e: number, f: number, g: number, h: number, i: number, j: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: any, q: number, r: number, s: any, t: any, u: any, v: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: any, q: number, r: number, s: any, t: any, u: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_plain_put_payload_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: any, x: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_compact_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: any, x: any, y: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: any, y: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_cached_plan_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: any, y: any, z: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: any, q: any, r: number, s: number, t: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_batch_transaction: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: any, p: any, q: number, r: number, s: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_plain_put_payload_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_compact_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: any, z: any, a1: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_document_index_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number, u: number, v: number, w: number, x: number, y: any, z: any, a1: any, b1: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_transaction: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_committed_no_next_storage_append_transaction_trim: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_facts: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_facts_document_index: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: any, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: any, t: any, u: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_facts_document_index_cached_plan: (a: number, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: any, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: any, s: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_latest_facts_document_index_cached_plan_trim_hashes: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: any, p: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_latest_facts_document_index_trim_hashes: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: any, j: number, k: number, l: number, m: number, n: number, o: number, p: any, q: any, r: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: any, q: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_plain_put_payload: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: any, r: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_compact_trim_hashes_plain_put_payload: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_cached_plan_trim_hashes: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: any, r: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_compact: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: any, r: any, s: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_compact_trim_hashes: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: any, s: any, t: any) => [number, number, number];
    readonly nativepeerbitbackbone_prepare_plain_entry_commit_no_next_facts_document_index_trim_hashes: (a: number, b: bigint, c: number, d: number, e: number, f: number, g: any, h: any, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: any, s: any, t: any) => [number, number, number];
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
    readonly __wbg_nativeentryv0plainbuilder_free: (a: number, b: number) => void;
    readonly __wbg_nativelogblockstore_free: (a: number, b: number) => void;
    readonly __wbg_nativelogindex_free: (a: number, b: number) => void;
    readonly benchmark_entry_v0_storage_verify_modes: (a: any, b: any, c: any, d: number, e: any) => [number, number, number];
    readonly benchmark_plain_entry_v0_core: (a: any, b: any, c: any, d: number, e: any) => [number, number, number];
    readonly benchmark_plain_entry_v0_crypto: (a: any, b: any, c: any, d: number, e: any) => [number, number, number];
    readonly benchmark_plain_entry_v0_digest_key_core: (a: any, b: any, c: any, d: number, e: any) => [number, number, number];
    readonly block_response_payload: (a: number, b: number, c: number) => [number, number];
    readonly calculate_raw_cid_v1: (a: any) => [number, number];
    readonly calculate_raw_cid_v1_batch: (a: any) => [number, number, number];
    readonly encode_entry_v0_signable: (a: any, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any) => [number, number, number];
    readonly encode_entry_v0_signable_batch: (a: any, b: any, c: any, d: any, e: any, f: any, g: any, h: any) => [number, number, number];
    readonly encode_entry_v0_storage: (a: any, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: any, k: any, l: number) => [number, number, number];
    readonly encode_entry_v0_storage_batch_with_cids: (a: any, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any, k: any) => [number, number, number];
    readonly encode_entry_v0_storage_with_cid: (a: any, b: bigint, c: number, d: number, e: number, f: any, g: number, h: any, i: any, j: any, k: any, l: number) => [number, number, number];
    readonly entry_v0_plain_payload_data_from_storage: (a: any) => [number, number, number];
    readonly nativeentryv0plainbuilder_new: (a: any, b: any, c: any) => [number, number, number];
    readonly nativelogblockstore_clear: (a: number) => void;
    readonly nativelogblockstore_delete: (a: number, b: number, c: number) => number;
    readonly nativelogblockstore_delete_many: (a: number, b: any) => [number, number, number];
    readonly nativelogblockstore_entries: (a: number) => any;
    readonly nativelogblockstore_get: (a: number, b: number, c: number) => [number, number];
    readonly nativelogblockstore_get_many: (a: number, b: any) => [number, number, number];
    readonly nativelogblockstore_has: (a: number, b: number, c: number) => number;
    readonly nativelogblockstore_has_many: (a: number, b: any) => [number, number, number];
    readonly nativelogblockstore_len: (a: number) => number;
    readonly nativelogblockstore_new: () => number;
    readonly nativelogblockstore_put: (a: number, b: number, c: number, d: number, e: number) => void;
    readonly nativelogblockstore_put_many: (a: number, b: any, c: any) => [number, number];
    readonly nativelogblockstore_size: (a: number) => number;
    readonly nativelogindex_child_join_entries: (a: number, b: number, c: number) => any;
    readonly nativelogindex_children: (a: number, b: number, c: number) => any;
    readonly nativelogindex_clear: (a: number) => void;
    readonly nativelogindex_count_has_next: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly nativelogindex_delete: (a: number, b: number, c: number) => number;
    readonly nativelogindex_delete_many: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_entry_metadata_batch: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_entry_metadata_hints_batch: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_has: (a: number, b: number, c: number) => number;
    readonly nativelogindex_has_any_head: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_has_any_head_batch: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_has_head: (a: number, b: number, c: number) => number;
    readonly nativelogindex_has_many: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_head_data_entries: (a: number, b: number, c: number) => any;
    readonly nativelogindex_head_entries: (a: number, b: number, c: number) => any;
    readonly nativelogindex_head_join_entries: (a: number, b: number, c: number) => any;
    readonly nativelogindex_heads: (a: number, b: number, c: number) => any;
    readonly nativelogindex_len: (a: number) => number;
    readonly nativelogindex_max_head_data_u32: (a: number, b: number, c: number) => any;
    readonly nativelogindex_max_head_data_u32_batch: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_new: () => number;
    readonly nativelogindex_newest_hash: (a: number) => any;
    readonly nativelogindex_oldest_entries: (a: number, b: number) => any;
    readonly nativelogindex_oldest_hash: (a: number) => any;
    readonly nativelogindex_payload_size_sum: (a: number) => number;
    readonly nativelogindex_plan_delete_recursively: (a: number, b: any, c: number) => [number, number, number];
    readonly nativelogindex_plan_join: (a: number, b: number, c: number, d: any, e: number, f: number, g: number, h: number, i: number, j: bigint, k: number) => [number, number, number];
    readonly nativelogindex_plan_join_batch: (a: number, b: any, c: any, d: any, e: number, f: any, g: any, h: any, i: number) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_chain_and_put: (a: number, b: any, c: any, d: any, e: any, f: any, g: number, h: number, i: any, j: number, k: any, l: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_chain_commit_blocks_and_put: (a: number, b: number, c: any, d: any, e: any, f: any, g: any, h: number, i: number, j: any, k: number, l: any, m: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entries_commit_blocks_and_put_with_builder: (a: number, b: number, c: number, d: any, e: any, f: any, g: any, h: number, i: any, j: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entries_no_next_commit_blocks_and_put_with_builder: (a: number, b: number, c: number, d: any, e: any, f: any, g: number, h: any, i: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_and_put: (a: number, b: any, c: any, d: any, e: bigint, f: number, g: number, h: number, i: any, j: number, k: any, l: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_and_put_with_builder: (a: number, b: number, c: bigint, d: number, e: number, f: number, g: any, h: number, i: any, j: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_block_and_put: (a: number, b: number, c: any, d: any, e: any, f: bigint, g: number, h: number, i: number, j: any, k: number, l: any, m: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_block_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: any, i: number, j: any, k: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_facts_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: any, i: number, j: any, k: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_facts_trim_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: any, i: number, j: any, k: any, l: number) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_facts_trim_hashes_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: any, i: number, j: any, k: any, l: number) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_no_next_facts_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: number, i: any, j: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_no_next_facts_trim_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: number, i: any, j: any, k: number) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_commit_no_next_facts_trim_hashes_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: number, i: any, j: any, k: number) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_storage_and_put_with_builder: (a: number, b: number, c: bigint, d: number, e: number, f: number, g: any, h: number, i: any, j: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_storage_commit_block_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: any, i: number, j: any, k: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_storage_commit_block_trim_and_put_with_builder: (a: number, b: number, c: number, d: bigint, e: number, f: number, g: number, h: any, i: number, j: any, k: any, l: number) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_storage_facts_and_put_with_builder: (a: number, b: number, c: bigint, d: number, e: number, f: number, g: any, h: number, i: any, j: any) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_storage_facts_trim_and_put_with_builder: (a: number, b: number, c: bigint, d: number, e: number, f: number, g: any, h: number, i: any, j: any, k: number) => [number, number, number];
    readonly nativelogindex_prepare_entry_v0_plain_entry_storage_trim_and_put_with_builder: (a: number, b: number, c: bigint, d: number, e: number, f: number, g: any, h: number, i: any, j: any, k: number) => [number, number, number];
    readonly nativelogindex_put: (a: number, b: number, c: number, d: number, e: number, f: any, g: number, h: bigint, i: number, j: number, k: number, l: any) => [number, number];
    readonly nativelogindex_put_append_chain: (a: number, b: any, c: number, d: number, e: any, f: number, g: any, h: any, i: any, j: any) => [number, number];
    readonly nativelogindex_put_many: (a: number, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any) => [number, number];
    readonly nativelogindex_shadowed_gids: (a: number, b: number, c: number, d: any, e: number, f: number) => [number, number, number];
    readonly nativelogindex_unique_reference_gid_rows_batch: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_unique_reference_gid_rows_flat_batch: (a: number, b: any) => [number, number, number];
    readonly nativelogindex_unique_reference_gids: (a: number, b: number, c: number) => any;
    readonly prepare_entry_v0_plain_chain: (a: any, b: any, c: any, d: any, e: any, f: number, g: number, h: any, i: number, j: any, k: any) => [number, number, number];
    readonly prepare_entry_v0_plain_entry: (a: any, b: any, c: any, d: bigint, e: number, f: number, g: number, h: any, i: number, j: any, k: any) => [number, number, number];
    readonly prepare_raw_entry_v0_batch: (a: any) => [number, number, number];
    readonly sign_ed25519: (a: any, b: any, c: any) => [number, number, number];
    readonly verify_ed25519_batch: (a: any, b: any, c: any) => [number, number, number];
    readonly verify_entry_v0_ed25519_batch: (a: any, b: any, c: any, d: any, e: any, f: any, g: any, h: any, i: any, j: any) => [number, number, number];
    readonly verify_entry_v0_ed25519_storage_batch: (a: any) => [number, number, number];
    readonly __wbg_directblockdecodedmessage_free: (a: number, b: number) => void;
    readonly __wbg_directblockeagerindex_free: (a: number, b: number) => void;
    readonly __wbg_directblockprovidercache_free: (a: number, b: number) => void;
    readonly __wbg_directstreamlanes_free: (a: number, b: number) => void;
    readonly __wbg_directstreamroutes_free: (a: number, b: number) => void;
    readonly __wbg_directstreamseencache_free: (a: number, b: number) => void;
    readonly __wbg_fanouttreedecodedframe_free: (a: number, b: number) => void;
    readonly __wbg_topiccontroldecodedmessage_free: (a: number, b: number) => void;
    readonly __wbg_topiccontrolrootdirectory_free: (a: number, b: number) => void;
    readonly db_decode_block_message: (a: number, b: number) => [number, number, number];
    readonly db_default_provider_candidates: (a: number, b: number, c: number, d: number, e: number, f: number) => [number, number];
    readonly db_encode_block_request: (a: number, b: number) => [number, number];
    readonly db_encode_block_response: (a: number, b: number, c: number, d: number) => [number, number];
    readonly db_normalize_provider_hints: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly db_pick_request_batch: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly decode_and_verify_batch: (a: any, b: number) => [number, number];
    readonly decode_frame_to_json: (a: number, b: number) => [number, number, number, number];
    readonly directblockdecodedmessage_bytes_length: (a: number) => number;
    readonly directblockdecodedmessage_bytes_offset: (a: number) => number;
    readonly directblockdecodedmessage_cid: (a: number) => [number, number];
    readonly directblockdecodedmessage_variant: (a: number) => number;
    readonly directblockeagerindex_add: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly directblockeagerindex_clear: (a: number) => void;
    readonly directblockeagerindex_contains: (a: number, b: number, c: number) => number;
    readonly directblockeagerindex_current_bytes: (a: number) => number;
    readonly directblockeagerindex_del: (a: number, b: number, c: number) => void;
    readonly directblockeagerindex_len: (a: number) => number;
    readonly directblockeagerindex_new: (a: number, b: number, c: number) => number;
    readonly directblockeagerindex_sweep: (a: number, b: number) => [number, number];
    readonly directblockprovidercache_clear: (a: number) => void;
    readonly directblockprovidercache_get: (a: number, b: number, c: number, d: number) => [number, number];
    readonly directblockprovidercache_new: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly directblockprovidercache_remember_hints: (a: number, b: number, c: number, d: number, e: number, f: number) => void;
    readonly directblockprovidercache_remember_provider: (a: number, b: number, c: number, d: number, e: number, f: number) => void;
    readonly directstreamlanes_clear: (a: number) => void;
    readonly directstreamlanes_is_empty: (a: number) => number;
    readonly directstreamlanes_lane_bytes: (a: number, b: number) => number;
    readonly directstreamlanes_new: (a: number, b: number, c: number) => number;
    readonly directstreamlanes_push: (a: number, b: number, c: number) => number;
    readonly directstreamlanes_shift: (a: number) => number;
    readonly directstreamlanes_total_bytes: (a: number) => number;
    readonly directstreamroutes_add: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number) => number;
    readonly directstreamroutes_cleanup_pending: (a: number, b: number) => void;
    readonly directstreamroutes_clear: (a: number) => void;
    readonly directstreamroutes_count: (a: number, b: number, c: number) => number;
    readonly directstreamroutes_count_all: (a: number) => number;
    readonly directstreamroutes_dump_json: (a: number) => [number, number];
    readonly directstreamroutes_find_neighbor_json: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly directstreamroutes_get_dependent: (a: number, b: number, c: number) => [number, number];
    readonly directstreamroutes_get_fanout_json: (a: number, b: number, c: number, d: number, e: number, f: number) => [number, number];
    readonly directstreamroutes_get_prunable: (a: number, b: number, c: number) => [number, number];
    readonly directstreamroutes_get_route_hints_json: (a: number, b: number, c: number, d: number, e: number, f: number) => [number, number];
    readonly directstreamroutes_get_route_max_retention_period: (a: number) => number;
    readonly directstreamroutes_get_session: (a: number, b: number, c: number) => [number, number];
    readonly directstreamroutes_has_pending_cleanup: (a: number) => number;
    readonly directstreamroutes_has_target: (a: number, b: number, c: number) => number;
    readonly directstreamroutes_is_reachable: (a: number, b: number, c: number, d: number, e: number, f: number, g: number) => number;
    readonly directstreamroutes_new: (a: number, b: number, c: number, d: number, e: number, f: number, g: number) => number;
    readonly directstreamroutes_remove: (a: number, b: number, c: number) => [number, number];
    readonly directstreamroutes_remove_neighbour: (a: number, b: number, c: number) => void;
    readonly directstreamroutes_set_route_max_retention_period: (a: number, b: number) => void;
    readonly directstreamroutes_update_session: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly directstreamseencache_clear: (a: number) => void;
    readonly directstreamseencache_modify: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly directstreamseencache_new: (a: number, b: number) => number;
    readonly ds_ack_next_hop: (a: number, b: number, c: number, d: number) => [number, number];
    readonly ds_filter_flood_targets: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number) => [number, number];
    readonly ds_filter_silent_relay_recipients: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number) => [number, number];
    readonly ds_seek_ack_route_update: (a: number, b: number, c: number, d: number, e: number, f: number) => [number, number];
    readonly ds_select_redundancy_probes: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ds_should_acknowledge: (a: number, b: number, c: number) => number;
    readonly ds_should_ignore_data: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number) => number;
    readonly fanouttreedecodedframe_ack_token: (a: number) => bigint;
    readonly fanouttreedecodedframe_addrs: (a: number) => any;
    readonly fanouttreedecodedframe_bid_per_byte: (a: number) => number;
    readonly fanouttreedecodedframe_children: (a: number) => number;
    readonly fanouttreedecodedframe_data_write_drops: (a: number) => number;
    readonly fanouttreedecodedframe_dropped_forwards: (a: number) => number;
    readonly fanouttreedecodedframe_entry_addr_counts: (a: number) => [number, number];
    readonly fanouttreedecodedframe_entry_addrs: (a: number) => any;
    readonly fanouttreedecodedframe_entry_bids: (a: number) => [number, number];
    readonly fanouttreedecodedframe_entry_free_slots: (a: number) => [number, number];
    readonly fanouttreedecodedframe_entry_hashes: (a: number) => [number, number];
    readonly fanouttreedecodedframe_entry_levels: (a: number) => [number, number];
    readonly fanouttreedecodedframe_event: (a: number) => number;
    readonly fanouttreedecodedframe_flags: (a: number) => number;
    readonly fanouttreedecodedframe_free_slots: (a: number) => number;
    readonly fanouttreedecodedframe_has_ack: (a: number) => number;
    readonly fanouttreedecodedframe_has_have_range: (a: number) => number;
    readonly fanouttreedecodedframe_has_reply_route: (a: number) => number;
    readonly fanouttreedecodedframe_has_text: (a: number) => number;
    readonly fanouttreedecodedframe_have_from: (a: number) => number;
    readonly fanouttreedecodedframe_have_to_exclusive: (a: number) => number;
    readonly fanouttreedecodedframe_level: (a: number) => number;
    readonly fanouttreedecodedframe_max_children: (a: number) => number;
    readonly fanouttreedecodedframe_min_free_slots: (a: number) => number;
    readonly fanouttreedecodedframe_missing_seqs: (a: number) => number;
    readonly fanouttreedecodedframe_payload_offset: (a: number) => number;
    readonly fanouttreedecodedframe_reason: (a: number) => number;
    readonly fanouttreedecodedframe_reply_route: (a: number) => [number, number];
    readonly fanouttreedecodedframe_req_id: (a: number) => number;
    readonly fanouttreedecodedframe_reservation_token: (a: number) => number;
    readonly fanouttreedecodedframe_reserve_root_capacity: (a: number) => number;
    readonly fanouttreedecodedframe_route: (a: number) => [number, number];
    readonly fanouttreedecodedframe_seed: (a: number) => number;
    readonly fanouttreedecodedframe_seqs: (a: number) => [number, number];
    readonly fanouttreedecodedframe_text: (a: number) => [number, number];
    readonly fanouttreedecodedframe_ttl_ms: (a: number) => number;
    readonly fanouttreedecodedframe_want: (a: number) => number;
    readonly ft_decode_end: (a: number, b: number) => number;
    readonly ft_decode_ihave: (a: number, b: number) => number;
    readonly ft_decode_join_accept: (a: number, b: number) => number;
    readonly ft_decode_join_reject: (a: number, b: number) => number;
    readonly ft_decode_join_req: (a: number, b: number) => number;
    readonly ft_decode_join_response_req_id: (a: number, b: number) => number;
    readonly ft_decode_parent_probe_reply: (a: number, b: number) => number;
    readonly ft_decode_parent_probe_req: (a: number, b: number) => number;
    readonly ft_decode_provider_announce: (a: number, b: number) => number;
    readonly ft_decode_provider_notify: (a: number, b: number) => number;
    readonly ft_decode_provider_query: (a: number, b: number) => number;
    readonly ft_decode_provider_reply: (a: number, b: number) => number;
    readonly ft_decode_provider_subscribe: (a: number, b: number) => number;
    readonly ft_decode_repair_seqs: (a: number, b: number) => number;
    readonly ft_decode_route_query: (a: number, b: number) => number;
    readonly ft_decode_route_reply: (a: number, b: number) => number;
    readonly ft_decode_tracker_announce: (a: number, b: number) => number;
    readonly ft_decode_tracker_feedback: (a: number, b: number) => number;
    readonly ft_decode_tracker_query: (a: number, b: number) => number;
    readonly ft_decode_tracker_reply: (a: number, b: number) => number;
    readonly ft_decode_unicast: (a: number, b: number) => number;
    readonly ft_decode_unicast_ack: (a: number, b: number) => number;
    readonly ft_encode_data: (a: number, b: number) => [number, number];
    readonly ft_encode_end: (a: number, b: number, c: number) => [number, number];
    readonly ft_encode_fetch_req: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ft_encode_ihave: (a: number, b: number, c: number, d: number) => [number, number];
    readonly ft_encode_join_accept: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number) => [number, number];
    readonly ft_encode_join_reject: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: any) => [number, number];
    readonly ft_encode_join_req: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ft_encode_kick: (a: number, b: number) => [number, number];
    readonly ft_encode_leave: (a: number, b: number) => [number, number];
    readonly ft_encode_parent_probe_reply: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: number) => [number, number];
    readonly ft_encode_parent_probe_req: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ft_encode_provider_announce: (a: number, b: number, c: number, d: any) => [number, number];
    readonly ft_encode_provider_notify: (a: number, b: number, c: number, d: number, e: number, f: number, g: any) => [number, number];
    readonly ft_encode_provider_query: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ft_encode_provider_reply: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any) => [number, number];
    readonly ft_encode_provider_subscribe: (a: number, b: number, c: number, d: number) => [number, number];
    readonly ft_encode_provider_unsubscribe: (a: number, b: number) => [number, number];
    readonly ft_encode_publish_proxy: (a: number, b: number, c: number, d: number) => [number, number];
    readonly ft_encode_repair_req: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ft_encode_route_query: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ft_encode_route_reply: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly ft_encode_tracker_announce: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: any) => [number, number];
    readonly ft_encode_tracker_feedback: (a: number, b: number, c: number, d: number, e: number, f: number) => [number, number];
    readonly ft_encode_tracker_query: (a: number, b: number, c: number, d: number) => [number, number];
    readonly ft_encode_tracker_reply: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: number, n: any) => [number, number];
    readonly ft_encode_unicast: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: bigint, i: number, j: number) => [number, number];
    readonly ft_encode_unicast_ack: (a: number, b: number, c: bigint, d: number, e: number) => [number, number];
    readonly ft_pu_evaluate_gate: (a: number, b: number, c: number, d: number, e: number, f: number, g: number, h: number, i: number, j: number, k: number, l: number, m: number, n: number, o: number, p: number, q: number, r: number, s: number, t: number) => number;
    readonly ft_pu_normalize_policy: (a: number, b: number) => [number, number];
    readonly reencode_frame: (a: number, b: number) => [number, number, number, number];
    readonly signable_bytes: (a: number, b: number) => [number, number, number, number];
    readonly tc_decode_pubsub_message: (a: number, b: number) => [number, number, number];
    readonly tc_encode_get_subscribers: (a: number, b: number) => [number, number];
    readonly tc_encode_peer_unavailable: (a: number, b: number, c: bigint, d: bigint, e: number, f: number) => [number, number];
    readonly tc_encode_pubsub_data: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly tc_encode_subscribe: (a: number, b: number, c: number) => [number, number];
    readonly tc_encode_topic_root_candidates: (a: number, b: number) => [number, number];
    readonly tc_encode_topic_root_query: (a: number, b: number, c: number) => [number, number];
    readonly tc_encode_topic_root_query_response: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly tc_encode_unsubscribe: (a: number, b: number) => [number, number];
    readonly tc_normalize_auto_candidates: (a: number, b: number, c: number, d: number) => [number, number];
    readonly tc_shard_topic: (a: number, b: number, c: number, d: number, e: number) => [number, number];
    readonly tc_subscribe_should_replace: (a: number, b: bigint, c: bigint) => number;
    readonly tc_subscription_is_latest: (a: number, b: number, c: bigint, d: bigint) => number;
    readonly tc_topic_hash32: (a: number, b: number) => number;
    readonly test_corpus_frames: () => any;
    readonly topiccontroldecodedmessage_data_length: (a: number) => number;
    readonly topiccontroldecodedmessage_data_offset: (a: number) => number;
    readonly topiccontroldecodedmessage_flag: (a: number) => number;
    readonly topiccontroldecodedmessage_request_id: (a: number) => number;
    readonly topiccontroldecodedmessage_root: (a: number) => [number, number];
    readonly topiccontroldecodedmessage_text: (a: number) => [number, number];
    readonly topiccontroldecodedmessage_timestamp: (a: number) => bigint;
    readonly topiccontroldecodedmessage_topics: (a: number) => [number, number];
    readonly topiccontroldecodedmessage_variant: (a: number) => number;
    readonly topiccontrolrootdirectory_delete_root: (a: number, b: number, c: number) => void;
    readonly topiccontrolrootdirectory_get_default_candidates: (a: number) => [number, number];
    readonly topiccontrolrootdirectory_get_root: (a: number, b: number, c: number) => [number, number];
    readonly topiccontrolrootdirectory_new: () => number;
    readonly topiccontrolrootdirectory_resolve_deterministic_candidate: (a: number, b: number, c: number) => [number, number];
    readonly topiccontrolrootdirectory_set_default_candidates: (a: number, b: number, c: number) => void;
    readonly topiccontrolrootdirectory_set_root: (a: number, b: number, c: number, d: number, e: number) => void;
    readonly topiccontroldecodedmessage_session: (a: number) => bigint;
    readonly __wbindgen_malloc: (a: number, b: number) => number;
    readonly __wbindgen_realloc: (a: number, b: number, c: number, d: number) => number;
    readonly __wbindgen_exn_store: (a: number) => void;
    readonly __externref_table_alloc: () => number;
    readonly __wbindgen_externrefs: WebAssembly.Table;
    readonly __externref_table_dealloc: (a: number) => void;
    readonly __wbindgen_free: (a: number, b: number, c: number) => void;
    readonly __externref_drop_slice: (a: number, b: number) => void;
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
