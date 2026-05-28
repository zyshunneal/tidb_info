# TiDB 系统学习计划

> 目标：通过 100 个核心知识点 + 100 个动手实验 + 100 个问题诊断场景，
> 系统掌握 TiDB 的体系架构、核心原理、内部实现、生态工具与日常运维。
>
> 建议学习路径：先理论（知识点）→ 再实操（实验）→ 再实战（诊断场景）。
> 每周覆盖约 10–15 项，预计 8–12 周完成全部内容。
>
> 配套官方文档（按需对照）：
> - 中文文档：https://docs.pingcap.com/zh/tidb/stable
> - 英文文档：https://docs.pingcap.com/tidb/stable
> - 源码仓库：https://github.com/pingcap/tidb 、https://github.com/tikv/tikv 、https://github.com/tikv/pd
> - TiDB Internals 论坛：https://internals.tidb.io

---

## 第一部分：100 个 TiDB 核心知识点

### 第一章 体系架构与核心组件（1–15）

1. TiDB 的整体架构：TiDB Server（计算层）+ TiKV（行存）+ TiFlash（列存）+ PD（调度）的职责划分与交互。
2. 计算与存储分离：TiDB Server 无状态、TiKV 有状态的设计动机及水平扩展能力。
3. TiDB Server 的角色：SQL 解析、优化、执行、事务协调、连接管理与会话状态。
4. PD 的核心职责：集群元信息管理、TSO 时间戳服务、Region 调度、负载均衡。
5. TiKV 的核心职责：分布式 KV 存储、Raft 复制组、MVCC、分布式事务参与者。
6. TiFlash 的角色：列存副本、向量化执行、MPP 引擎、HTAP 实时分析能力。
7. Placement Driver（PD）集群的多副本选举与 etcd embedded 用法。
8. TSO 全局单调递增时间戳的实现原理与 PD Leader 单点性能上限。
9. Region 的概念：默认 96MB 分片、按 key range 切分、Raft Group 单位。
10. Store 的概念：TiKV 节点对应一个或多个 Store，Region 副本分布于 Store。
11. Leader / Follower / Learner 角色的差异以及读写路径选择。
12. TiDB 计算下推（Coprocessor）原理：算子下推到 TiKV/TiFlash 减少网络数据传输。
13. gRPC / Protobuf 在 TiDB 内部各组件通信中的使用方式。
14. TiDB 与 MySQL 协议的兼容范围及不兼容点（如外键、存储过程、JSON 索引等）。
15. TiDB 版本演进：从 1.x 到 7.x/8.x，重要里程碑（如 TiFlash、SPM、资源管控、Serverless）。

### 第二章 TiKV 存储引擎与分布式存储（16–30）

16. RocksDB 作为 TiKV 底层存储引擎：LSM-Tree、Column Family、Compaction、Bloom Filter。
17. TiKV 中两个 RocksDB 实例：raftdb（Raft 日志）与 kvdb（数据）。
18. Titan 引擎：大 Value 分离存储原理与适用场景。
19. Raft 协议核心：Leader 选举、日志复制、提交、安全性证明思想。
20. Raft 日志压缩与 Snapshot 机制，Snapshot 生成与发送对性能的影响。
21. MultiRaft：Region 级别独立 Raft Group 的批处理优化（Hibernate Region、Async IO Pool）。
22. MVCC 实现：start_ts/commit_ts、Lock CF / Default CF / Write CF 的三列族结构。
23. Percolator 模型：分布式事务的两阶段提交在 TiKV 上的实现。
24. 异步提交（Async Commit）与一阶段提交（1PC）的原理与触发条件。
25. RawKV 与 TxnKV 两种 API 模式差异，适用场景。
26. Coprocessor：表达式下推、聚合下推、Limit/TopN 下推执行模型。
27. Region 分裂（Split）：触发条件（大小、key 数、热点）、流程与影响。
28. Region 合并（Merge）：触发条件、空 Region 合并与对调度的影响。
29. 热点 Region 识别机制：读热点、写热点统计与 PD hot region scheduler。
30. Placement Rules：副本数、隔离级别、Label 约束（Region、Zone、Host、Rack）。

### 第三章 PD 调度与元数据管理（31–40）

31. PD 调度器种类：balance-leader、balance-region、hot-region、evict-leader 等。
32. Operator 与 Step：PD 生成调度操作的最小单元，限流与冲突避免。
33. PD 调度评分模型：region size、leader count、store score 的计算。
34. PD 心跳：Store heartbeat、Region heartbeat 间隔与对调度的反馈。
35. PD 元信息：TSO 分配、Region 路由表、Store 信息的持久化与 etcd 角色。
36. Label & Topology：通过 location-labels 实现机房/机架级容灾。
37. Placement Rules in SQL：以 SQL 形式管理数据放置策略。
38. Region cache 在 TiDB Server 中的缓存与失效（NotLeader 重定向、backoff）。
39. PD API：pd-ctl 常用命令（store、region、scheduler、config、cluster）。
40. PD HA：奇数节点部署、Leader 切换、最小可用节点数。

### 第四章 TiDB Server 与 SQL 引擎（41–55）

41. SQL 处理流程：词法/语法解析（parser）→ 预处理 → 逻辑优化 → 物理优化 → 执行。
42. AST 与 Plan Tree：plannercore 中 LogicalPlan/PhysicalPlan 的转换链。
43. 基于代价的优化（CBO）：Statistics、直方图（Histogram）、Count-Min Sketch、TopN。
44. 统计信息收集：ANALYZE TABLE、auto-analyze、Feedback 机制。
45. 执行引擎：Volcano 火山模型与向量化执行（chunk-based 批处理）。
46. SQL Hint：/*+ HASH_JOIN(t1) */ 等强制干预优化器的方法。
47. SQL Plan Management（SPM）：BINDING、auto capture，固化执行计划。
48. 索引类型：唯一索引、联合索引、表达式索引、不可见索引、聚簇索引（CIK）。
49. 聚簇表（Clustered Index）vs 非聚簇表的差异、_tidb_rowid 行为。
50. Auto Increment 与 AutoRandom：高并发下的全局 ID 分配机制与冲突。
51. View / Sequence / TTL Table / 分区表的基本概念与限制。
52. 分区表（Range、Hash、List、Range Columns、Key）的内部实现。
53. 临时表（Local / Global Temporary Table）的语义。
54. SQL 执行计划：EXPLAIN、EXPLAIN ANALYZE、EXPLAIN FOR CONNECTION 用法。
55. 慢日志（slow log）、tidb_slow_query 表与 expensive query 阈值。

### 第五章 分布式事务与一致性（56–65）

56. 两种事务模型：乐观事务（Optimistic）与悲观事务（Pessimistic）。
57. 悲观事务的加锁：in-memory pessimistic lock、async lock。
58. 隔离级别：可重复读（Repeatable Read，TiDB 实际为 Snapshot Isolation）。
59. tidb_txn_mode、tidb_skip_isolation_level_check 等关键事务变量。
60. 大事务限制：txn-total-size-limit、txn-entry-size-limit，及分段提交策略。
61. 自动重试（tidb_disable_txn_auto_retry）适用与风险。
62. 读已提交（Read Committed）支持及与 MySQL 行为差异。
63. 分布式死锁检测：Deadlock Detector、INFORMATION_SCHEMA.DEADLOCKS。
64. Stale Read / Follower Read / Read Replica Scaling 三种读优化方式。
65. CDC 一致性保证：TiCDC 的 changefeed 模型与 commit_ts 排序。

### 第六章 HTAP 与 TiFlash（66–75）

66. TiFlash 的列存模型（DeltaTree）与与 TiKV 的差异。
67. TiFlash 与 TiKV 的数据同步：Raft Learner 角色与 Region snapshot 同步。
68. TiFlash 的写入路径：Delta Layer、Stable Layer、Compaction。
69. MPP 模式：Exchange、Broadcast、HashPartition Sender 与 Plan Fragment。
70. Optimizer 路由：CBO 如何在 TiKV 与 TiFlash 间选择物理表。
71. tiflash_replica_table、TiFlash 副本 ALTER TABLE ... SET TIFLASH REPLICA 用法。
72. TiFlash 资源隔离：tiflash_mem_quota、tiflash_max_threads 等。
73. TiFlash 与列存索引（ColumnarIndex / Lucene）等新功能。
74. TiFlash 异常副本恢复与重建流程。
75. HTAP 适用场景与限制：实时分析、聚合、JOIN、不适合 OLTP 高频写后立即列存查询。

### 第七章 生态工具与数据迁移（76–85）

76. TiUP：集群部署、升级、扩缩容、playground、cluster、dm 等组件管理。
77. TiUP cluster 操作模型：拓扑文件（topology.yaml）、meta.yaml、tiup-cluster 命令。
78. BR（Backup & Restore）：基于 SST 文件的物理备份与恢复。
79. Dumpling：逻辑导出工具，支持并发、表过滤、SQL/CSV 输出。
80. TiDB Lightning：高速导入（local backend、tidb backend、physical/logical 模式）。
81. TiDB Data Migration（DM）：MySQL → TiDB 全量+增量复制，shard merge。
82. TiCDC：捕获 TiKV change log → Kafka / MySQL / S3 / Pulsar 下游。
83. sync-diff-inspector：上下游数据一致性校验。
84. PCP / Prometheus / Grafana / TiDB Dashboard：监控生态。
85. TiSpark / TiDB Connector for Flink：大数据集成方案。

### 第八章 运维监控与高可用（86–95）

86. TiDB 部署拓扑：最小生产拓扑、跨 AZ 部署、跨地域多活。
87. 滚动升级：tiup cluster upgrade，灰度策略与回滚思路。
88. 在线扩缩容：scale-out / scale-in，对 PD 调度负载的影响。
89. 关键监控指标：QPS、Duration、Region 数、Store 容量、PD Leader 切换。
90. Alert Rules：磁盘、Raftstore CPU、TiKV channel full、PD operator pending。
91. 集群健康检查：tiup cluster check、Display、Status。
92. TiDB Dashboard：Key Visualizer、Top SQL、慢查询、流量可视化。
93. Continuous Profiling：连续性能采集（火焰图）。
94. 滚动重启与维护窗口：tiup cluster restart 单组件、--node 参数。
95. 高可用架构：3 TiKV / 5 TiKV / 跨机房多副本，Placement Rules 配合。

### 第九章 安全、新特性与生态扩展（96–100）

96. 用户与权限：MySQL 兼容的权限模型、TLS 加密、SSL 客户端证书。
97. 资源管控（Resource Control）：Resource Group、RU（Request Unit）、限流与优先级。
98. TiDB Serverless / TiDB Cloud Dedicated：托管形态的运维模型差异。
99. 加密：透明数据加密（TDE）、KMS 集成。
100. 新特性追踪方向：Fast DDL / Reorg、Index Merge、向量索引、Cascades planner 演进。

---

## 第二部分：100 个动手实验

> 建议每个实验记录：环境、操作命令、关键现象、监控截图、结论。

### 第一章 环境部署与初始化（1–10）

1. 使用 tiup playground 在本地启动 1 TiDB + 1 TiKV + 1 PD 单机集群。
2. 使用 tiup playground --tiflash 启动包含 TiFlash 的 HTAP 集群并验证副本同步。
3. 编写最小生产拓扑 topology.yaml，部署 3 TiKV + 3 PD + 2 TiDB 集群。
4. 使用 tiup cluster deploy / start / display 完成部署，并查看每个节点的状态。
5. 配置 systemd 自启动并模拟节点重启，观察集群自动恢复。
6. 启用 TLS：生成 CA、Server、Client 证书并部署带 TLS 的集群。
7. 修改部署拓扑端口、deploy_dir 与 data_dir，验证目录结构及日志路径。
8. 部署 TiDB Dashboard + Prometheus + Grafana + Alertmanager，并打开监控面板。
9. 使用 tiup cluster check 检查节点 OS、内核参数（vm.swappiness、ulimit、THP）。
10. 升级集群：tiup cluster upgrade 到下一个补丁版本，观察滚动升级过程。

### 第二章 基础 SQL 与数据建模（11–20）

11. 创建测试库与聚簇表 / 非聚簇表，对比 EXPLAIN 输出和 _tidb_rowid 行为。
12. 使用 AUTO_RANDOM 主键设计高并发写入表，观察热点缓解效果。
13. 创建 Range / Hash / List 分区表，插入数据并查看 SHOW TABLE STATUS。
14. 使用 EXPLAIN ANALYZE 分析一个全表扫描，将其改为索引访问。
15. 创建联合索引并设计能命中索引的 SQL，对比改写前后执行时间。
16. 使用 ANALYZE TABLE 收集统计信息并查看 SHOW STATS_META / STATS_HISTOGRAMS。
17. 使用 SQL Binding 固化 Hash Join 计划，避免计划抖动。
18. 创建 GLOBAL TEMPORARY TABLE，并验证多会话不共享数据。
19. 创建 TTL TABLE 并验证自动清理过期数据。
20. 编写包含子查询、窗口函数、CTE 的复杂 SQL，并查看执行计划差异。

### 第三章 集群运维操作（21–35）

21. 在线扩容 1 TiKV 节点，观察 PD 自动均衡 Region 与 Leader 数。
22. 在线缩容 1 TiKV 节点（scale-in），观察 evict-leader 与 region 迁移流程。
23. 通过 pd-ctl 手动切换 PD Leader，观察 TiDB Server 重连行为。
24. 使用 tiup cluster edit-config 调整 TiKV raftstore.apply-pool-size 并 reload。
25. 通过 pd-ctl 创建 evict-leader-scheduler，模拟某 store 离线维护。
26. 使用 pd-ctl region 查询单个 Region 的副本分布、Leader 位置。
27. 使用 pd-ctl operator add transfer-leader 手动迁移 Leader。
28. 通过 store delete 安全下线一台 TiKV 并验证完成条件。
29. 修改 region-schedule-limit / leader-schedule-limit，观察调度速度变化。
30. 配置 Placement Rules 实现跨机房 3-2-1 副本分布。
31. 使用 SQL `ALTER TABLE … PLACEMENT POLICY` 定义放置策略并验证。
32. 升级 TiUP 自身：tiup update --self / tiup update --all。
33. 配置 grafana_user 自定义密码并 reload 监控。
34. 增加 TiDB Server 节点，并在 HAProxy / ProxySQL 后端做负载均衡。
35. 使用 systemctl 模拟 TiKV 进程 OOM，并观察 Raft 选举与 Leader 切换。

### 第四章 备份恢复与数据迁移（36–50）

36. 使用 BR 全量备份到本地目录，并测量备份速率与磁盘占用。
37. 使用 BR 备份到对象存储（S3 / GCS / OSS）。
38. 使用 BR restore 全量恢复到新集群，验证数据一致性。
39. 使用 BR 日志备份（PITR）：启动 log backup，并执行时间点恢复。
40. 使用 Dumpling 导出 csv，按 where 条件、表过滤、并发参数测试速率。
41. 使用 TiDB Lightning local backend 导入 1000 万行数据。
42. 使用 TiDB Lightning tidb backend 导入并观察对业务集群影响。
43. 配置 DM：使用 source.yaml + task.yaml 同步一个 MySQL 库到 TiDB。
44. 使用 DM 进行分库分表合并（shard merge）。
45. 模拟 DM 断点续传：人为 kill worker，验证从 checkpoint 恢复。
46. 配置 TiCDC：将 TiDB 变更同步到 Kafka，使用 canal-json 格式。
47. 配置 TiCDC 同步到下游 MySQL，并使用 sync-diff-inspector 校验。
48. 使用 sync-diff-inspector 对比上下游差异，并修复不一致。
49. 使用 BR + TiCDC 组合实现“全量+增量”的迁移演练。
50. 跨版本数据迁移：从 6.5 LTS 迁移到 7.5 LTS，观察新特性差异。

### 第五章 性能压测与调优（51–65）

51. 使用 sysbench oltp_point_select 压测点查 QPS。
52. 使用 sysbench oltp_read_write 压测 OLTP 混合负载。
53. 使用 go-tpc 执行 TPC-C，观察 tpmC 和延迟分布。
54. 使用 go-tpc 执行 TPC-H，观察 TiFlash MPP 加速比。
55. 调整 tidb_distsql_scan_concurrency / tidb_index_lookup_concurrency 观察查询变化。
56. 启用 Follower Read，对比读延迟与 Leader Read。
57. 启用 Stale Read（set @@tidb_read_staleness = -5），观察读路径。
58. 测试 Async Commit / 1PC 开启前后 commit 延迟差异。
59. 调整 raftstore.store-pool-size / apply-pool-size 观察吞吐影响。
60. 修改 tikv.block-cache.capacity，对比缓存命中率与延迟。
61. 在写热点表上验证 SHARD_ROW_ID_BITS / AUTO_RANDOM 缓解效果。
62. 使用 EXPLAIN ANALYZE + Top SQL 找出最耗 CPU 的 SQL 并改写。
63. 使用 Continuous Profiling 抓取火焰图，定位 TiKV CPU 热点。
64. 使用 Resource Control 创建多个 Resource Group，限制低优先组 RU。
65. 模拟突发流量，观察 Resource Group 限流与排队行为。

### 第六章 HTAP 与 TiFlash 实战（66–75）

66. 给一张 OLTP 表 ALTER TABLE … SET TIFLASH REPLICA 2，观察同步进度。
67. 在 TiFlash 上跑聚合 SQL，对比 TiKV / TiFlash 两条物理路径耗时。
68. 启用 MPP（tidb_allow_mpp = ON），观察 EXPLAIN 中 ExchangeSender/Receiver。
69. 在 TiFlash 上跑 TPC-H Q1/Q5/Q9 并记录耗时。
70. 模拟 TiFlash 节点宕机，观察副本恢复与查询自动回退。
71. 使用 tiflash-ctl 查看 region 同步与状态。
72. 对一张表禁用 TiFlash 副本，验证 SQL 自动改走 TiKV。
73. 测试 tidb_isolation_read_engines 在线切换查询引擎。
74. 调整 tiflash 资源参数（max_threads、mem_quota），对比并发能力。
75. 使用 TiFlash 列存索引（如向量索引或 Lucene-based 索引）做检索实验。

### 第七章 监控告警与诊断（76–85）

76. 在 Grafana 中查看 TiKV Raft / Coprocessor / Thread CPU 面板。
77. 使用 TiDB Dashboard 的 Key Visualizer 找出写热点 Region。
78. 使用 Dashboard 的 Top SQL 找出 CPU 占比最大的 SQL。
79. 使用 Dashboard 的 Slow Query 查询慢日志并按 digest 聚合。
80. 使用 Continuous Profiling 抓取 TiDB / TiKV / PD 火焰图。
81. 配置 Alertmanager Webhook，将告警接入企业微信 / 钉钉 / 飞书。
82. 自定义 Prometheus Recording Rules / Alert Rules。
83. 使用 SQL 诊断系统表：INFORMATION_SCHEMA.CLUSTER_*、STATEMENTS_SUMMARY。
84. 使用 SHOW PROCESSLIST + KILL TIDB 中断长查询。
85. 模拟磁盘满（fill disk）触发告警，观察 PD evict-leader 行为。

### 第八章 高级运维场景（86–100）

86. 模拟 PD 集群 1 节点宕机，验证 Leader 重选与 TSO 服务恢复时长。
87. 模拟 TiKV 整机宕机，验证 Region 迁移与可用性。
88. 模拟整个机房断电（多副本），验证 Placement Rules 容灾。
89. 升级失败回滚演练：使用 tiup cluster upgrade --transfer-timeout / 回退包。
90. 使用 unsafe-recover：tikv-ctl unsafe-recover remove-fail-stores 恢复多数派丢失。
91. 使用 pd-recover 在 PD 全部丢失时通过备份元数据重建。
92. 在线增加 TiFlash 节点并平衡列存副本。
93. 调整 GC 生命周期 tidb_gc_life_time，对比对长事务的影响。
94. 使用 ADMIN CHECK TABLE 校验索引与数据一致性。
95. 使用 ADMIN SHOW DDL / ADMIN CANCEL DDL JOB 管理 DDL 队列。
96. 在生产模拟一个跨 region 大事务，观察 1PC/Async Commit 触发情况。
97. 使用 cgroup / docker 限制 TiKV CPU/内存，复现资源不足故障。
98. 启用 TLS 双向认证，并使用 mysql client 配置证书连接。
99. 建立资源管控基线：为 OLTP 和 BI 报表设置不同 Resource Group。
100. 编写一键巡检脚本：调用 pd-ctl / tiup cluster / SQL 巡检集群健康度。

---

## 第三部分：100 个问题诊断场景

> 每个场景建议练习：复现方法 → 关键指标 → 排查路径 → 解决方案。

### 第一章 慢 SQL 与执行计划（1–15）

1. 一条原本秒级的 SQL 突然变慢，怀疑统计信息过期 → 排查 SHOW STATS_HEALTHY。
2. SQL 走错索引，使用 USE INDEX / FORCE INDEX / SPM 修正。
3. SQL 走了全表扫描，EXPLAIN 显示 TableFullScan，定位缺失索引。
4. SQL 在不同 TiDB Server 上计划不一致，排查 Plan Cache 命中和 Hint。
5. EXPLAIN ANALYZE 显示 cop_task 时间长，定位 Coprocessor 慢的 Region。
6. EXPLAIN 显示 Selection 下推失败（“not pushed down”），排查表达式与函数兼容性。
7. JOIN 顺序不合理导致大表先 Join：使用 LEADING / STRAIGHT_JOIN 修正。
8. Hash Join build 端选错（小表变 probe 端），排查 row count 估算误差。
9. limit/offset 大偏移导致慢，改写为 keyset pagination。
10. ORDER BY + LIMIT 没走索引，定位排序操作未下推。
11. IN (...) 列表过大导致 SQL 卡顿：评估改成临时表 join。
12. SQL Plan Cache 失效频繁（命中率低）：检查参数化与 statement summary。
13. tidb_slow_query 表里看到大量 SQL：批量 digest 聚合分析。
14. 同一 SQL 不同时段计划不同：分析 auto-analyze 抖动。
15. 视图嵌套或 CTE 物化策略导致 SQL 慢：使用 MATERIALIZE Hint。

### 第二章 热点与负载不均（16–25）

16. 写热点：自增主键导致单 Region 高 QPS，使用 AUTO_RANDOM 重构。
17. 读热点：热点 key 集中在某 Leader Region，开启 Follower Read 缓解。
18. PD Dashboard 显示 hot read/write region 集中，使用 split region 手动切分。
19. 某 TiKV CPU 飙高，其它节点空闲：定位单 store 热点 Leader 集中。
20. 业务表新建时全部写入同一 Region：预切分（pre-split）解决冷启动热点。
21. 时间序列表（按时间递增）持续热点：分区 + AUTO_RANDOM。
22. 大批量删除导致版本堆积、读热点：调整 GC + tidb_gc_scan_lock_mode。
23. 队列表（status 字段）热点：使用复合索引或 list 分区。
24. TiFlash 单节点 CPU 高：MPP 数据倾斜，使用更合适的 partition 表达式。
25. Storage capacity unbalanced：检查 Placement Rules、label 配置。

### 第三章 集群可用性故障（26–40）

26. TiDB Server 502 / 连接拒绝：排查进程存活、grpc 端口、TLS 证书。
27. TiKV down 后无法上线：日志 `Welcome to TiKV` 之后挂掉，排查 raft log 损坏。
28. PD Leader 频繁切换：网络抖动 / etcd 磁盘 IO 饱和。
29. PD 无法选主：节点数偶数或多数派失联，pd-recover 流程。
30. tiup cluster display 显示 Down 但进程存活：心跳端口或防火墙问题。
31. 滚动升级卡住：某 store 一直 transfer leader 不完成，检查 evict-leader-scheduler 残留。
32. TiKV 启动报 `cluster id mismatch`：误用旧数据目录加入新集群。
33. TiKV 启动报 `not enough space`：磁盘水位（capacity / available）触发只读。
34. PD 报 `region is heartbeat too frequently`：region 过多或心跳风暴。
35. TiDB 报 `region unavailable`：raft group 没有 leader，定位 Raft 日志状况。
36. 频繁 `TiKV server is busy`：scheduler full / write stall，调整 raftstore 参数。
37. TiKV write stall（RocksDB write-buffer/level0 太多）：compaction 落后。
38. 节点磁盘 IO util 100%：定位是 compaction、snapshot 还是业务写入。
39. TiKV channel full：apply-pool / store-pool 大小不足。
40. 重启后 region 长期未恢复 leader：pd-ctl operator show 看是否被 reject。

### 第四章 存储与 Region 异常（41–55）

41. Region 数过多（百万级）导致心跳压力：合并空 Region + 调大 region size。
42. Region miss peer（少副本）：定位失联 store 与 PD 重新补副本。
43. Region 有多余副本（extra peer）：等待 PD 调度或 force remove。
44. Learner 卡住不变 Voter：检查同步进度与 snapshot apply。
45. Stale region cache 导致 TiDB 报 NotLeader：触发 backoff / 重新加载。
46. RocksDB sst 损坏：tikv-ctl recover-mvcc / bad-ssts 处理。
47. Raft 日志膨胀（raftdb 占用大）：raft-log-gc 与 compact 配置。
48. TiKV 内存使用过高：block cache / write buffer / coprocessor 内存累计。
49. 大 Key / 大 Value：使用 tikv-ctl size 排查并改造业务模型。
50. Region split 失败：split-region-check-tick-interval 与 schedule 拥塞。
51. Region merge 后访问异常：tidb region cache 未刷新。
52. 单机多盘部署：data-dir 与 raftdb-path 分离对性能影响。
53. NVMe / SSD 磁盘性能下降：fsync 延迟监控与硬件检查。
54. tikv-ctl print 查看具体 key 编码：判断 row key / index key。
55. 大量 `TxnLockNotFound`：客户端事务超时与 GC 删除冲突。

### 第五章 事务与锁问题（56–65）

56. 大事务报错 `transaction too large`：拆分 batch 或调整 txn-total-size-limit。
57. 频繁 write conflict：乐观事务下重写为悲观事务或重试。
58. 死锁：从 INFORMATION_SCHEMA.DEADLOCKS 取栈、画锁等待图。
59. 长事务阻塞 GC：tidb_gc_life_time 触发 safe point 推不动。
60. 悲观锁等待超时：innodb_lock_wait_timeout / pessimistic-txn.wait-for-lock-timeout。
61. 异步提交事务一致性疑问：min-commit-ts、max-ts 取值理解。
62. GC 卡住：tidb_gc_safe_point 不前进，排查 long-running txn。
63. 读卡在 lock：select 触发 resolve lock，定位 lock 来源 region。
64. 多语句事务被 KILL：定位 SESSION 和 TRANSACTION ID 关联。
65. AUTO_INCREMENT 跳号：跨 TiDB Server 缓存与 region 切分关系。

### 第六章 TiFlash / HTAP 问题（66–75）

66. TiFlash 副本长期不可用：检查 raft learner 状态与 store 健康度。
67. TiFlash 查询比 TiKV 还慢：表过小或 MPP 启用前提（统计、谓词下推）。
68. MPP 计划未生效：tidb_allow_mpp / tidb_enforce_mpp / 列存副本是否同步完。
69. TiFlash OOM：调整 max_memory_usage / 限制并发 mpp task。
70. TiFlash 写入延迟高：Delta Layer flush 频率、磁盘 IO。
71. TiFlash 分裂同步异常：region 持续 in flight。
72. 查询 hot region 集中在 TiFlash 某节点：MPP 数据倾斜。
73. CDC 与 TiFlash 同步时延差异理解：commit_ts 推进。
74. ALTER … SET TIFLASH REPLICA 0 后未释放磁盘：等待 GC + compaction。
75. TiFlash 节点磁盘满：scale-in / 增加节点。

### 第七章 同步工具问题（76–85）

76. DM 任务报 GTID 丢失：上游 binlog 被清理，触发全量重做。
77. DM 报字符集不兼容：utf8mb4 与 utf8mb3 列定义对齐。
78. DM 出现重复 key：上下游主键差异或 safe-mode 配置。
79. TiCDC changefeed lag 持续增长：定位下游慢或网络瓶颈。
80. TiCDC 报 `event size too large`：调整 sink buffer 或拆分大事务。
81. TiCDC 与 TiKV GC 冲突：safe-point 被 changefeed 拉住。
82. Lightning 导入失败：checksum 不一致，校验源数据与跳过校验风险。
83. Lightning local backend 与业务集群共用：磁盘抢占与 PD 负载。
84. BR 备份失败：S3 权限 / 网络 timeout / Region scatter。
85. sync-diff-inspector 报数据不一致：定位时间窗口与缺失行。

### 第八章 性能瓶颈与资源问题（86–100）

86. CPU 使用率高但 QPS 低：定位是 raftstore 还是 unified read pool 瓶颈。
87. 磁盘 IO 高：拆分 compaction / write 路径，或升级硬件。
88. 网络带宽打满：定位是 region snapshot 还是业务读写。
89. TiDB Server 内存增长：执行计划缓存、prepare statement 泄漏。
90. TiKV unified-read-pool 不足：调整线程数与 limit。
91. coprocessor request 排队（grpc）大于阈值：拆分长查询。
92. region cache 老化频繁：检查 PD operator 是否过多。
93. PD operator pending 过多：调度限流 + 集群异常排查。
94. 突发请求触发 server is busy：使用 Resource Control 进行优先级限流。
95. 应用连接数飙高：使用连接池 / 中间件 / 限流。
96. 整库迁移后性能下降：统计信息丢失、热数据未预热。
97. 升级后某些 SQL 变慢：新优化器策略变化，使用 SPM 锁定旧计划。
98. 集群空载下持续 CPU 1 核占用：定位 background task（compact、gc、stats）。
99. 大量短连接：HAProxy timeout 与 TiDB token-limit 调整。
100. 客户端 ER_NET_PACKET_TOO_LARGE / read timeout：max_allowed_packet、wait_timeout 调整。

---

## 学习建议与进阶路径

1. 学习顺序建议：**架构总览 → 存储与事务原理 → SQL 与优化器 → HTAP → 生态工具 → 运维诊断**。
2. 每完成一个模块后，使用对应的实验进行验证；遇到现象再回到知识点章节复盘。
3. 强烈建议结合官方文档的【最佳实践】《TiDB 配置参数详解》《故障诊断》三类章节交叉阅读。
4. 阅读源码顺序推荐：`tidb/parser` → `tidb/planner` → `tidb/executor` → `tikv/raftstore` → `tikv/storage` → `pd/server/schedule`。
5. 想做深度运维方向：重点掌握 Raft / Region 调度 / GC / Backup & Restore / 监控告警体系。
6. 想做 SQL 性能方向：重点掌握 CBO、统计信息、执行计划、SPM、TiFlash MPP。
7. 想做 HTAP / 数据平台方向：重点掌握 TiFlash、TiCDC、TiSpark、Flink Connector 与下游链路。
8. 建议每月做一次**故障演练**：选 5 个诊断场景在测试集群上复现并记录复盘文档。

> 完成本计划后，你将具备从单机原理到生产运维、从 SQL 优化到分布式架构演进的全链路 TiDB 能力。
