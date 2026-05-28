# TiDB 周计划 / 阶段化学习排程

> 配套文件：[`TiDB-学习计划.md`](./TiDB-学习计划.md)（100 知识点 + 100 实验 + 100 诊断场景）
>
> 适用人群：已经有 TiDB 生产使用经验，希望系统补齐内部原理 + 全方向覆盖（OLTP / HTAP / 运维 / 工具链）。
>
> 时间模型：碎片化推进。本计划用「阶段」而非「自然周」，每个阶段建议 ~10–15 小时实际投入，可拉长到 1.5–2 个自然周。
>
> 全程预计：10 个阶段，理论按 8–12 周完成；碎片化节奏下可灵活拉到 16–20 周。

---

## 使用说明

1. **三件套并行**：每个阶段都包含「知识点（KP）+ 实验（EX）+ 诊断场景（DS）」，编号对应 `TiDB-学习计划.md` 中的条目。
2. **碎片时间切分建议**：
   - 通勤 / 短碎片（15–30 min）→ 读知识点 + 官方文档对照。
   - 晚上整段（1–2 h）→ 跑实验 + 看 Grafana 指标。
   - 周末整段（2–4 h）→ 综合诊断场景复现 + 写复盘。
3. **进度跟踪**：用本文件里的 `- [ ]` 复选框直接打钩。每个阶段末尾有「验收清单」，必须能口头复述 + 实操跑通才算结业。
4. **复盘频率**：每阶段结束写一份 200–500 字的复盘（贴在阶段末尾的"复盘"区即可），重点写**踩坑和反直觉的现象**。
5. **不必死磕顺序**：阶段 1–3 是地基，必须按序；阶段 4–10 可以根据当下工作场景插队（例如临时要排查慢 SQL 就直接做阶段 4）。

---

## 进度总览

- [ ] **阶段 1**：架构总览与环境部署（KP 1–15，EX 1–10，DS 选段）
- [ ] **阶段 2**：TiKV 存储引擎与 Raft（KP 16–25，EX 选段，DS 27/32/33/37/38/46/47）
- [ ] **阶段 3**：Region 调度与 PD（KP 26–40，EX 21–31，DS 16–25/28/29/34/41–44）
- [ ] **阶段 4**：SQL 引擎与优化器（KP 41–55，EX 11–20，DS 1–15）
- [ ] **阶段 5**：分布式事务与一致性（KP 56–65，EX 58/93/96，DS 55–65）
- [ ] **阶段 6**：HTAP 与 TiFlash（KP 66–75，EX 2/66–75，DS 24/66–75）
- [ ] **阶段 7**：生态工具与数据迁移（KP 76–85，EX 36–50，DS 76–85）
- [ ] **阶段 8**：性能压测与调优（KP 复盘 + EX 51–65，DS 86–100）
- [ ] **阶段 9**：运维监控告警与高可用（KP 86–95，EX 76–85，DS 补漏）
- [ ] **阶段 10**：安全、新特性、综合故障演练（KP 96–100，EX 86–100，DS 收尾）

---

## 阶段 1：架构总览与环境部署

> 目标：能在白板上画出 TiDB / TiKV / PD / TiFlash 的关系图，跑通最小生产拓扑，能解释 Region / Store / Leader 的概念差异。
>
> 预估时长：10–12 小时 ｜ 推荐节奏：阅读 4h + 实验 6h + 诊断 2h

### 知识点（KP 1–15）

- [ ] KP1 整体架构：4 大组件职责与交互
- [ ] KP2 计算存储分离的设计动机
- [ ] KP3 TiDB Server 的角色（无状态、SQL 处理、事务协调）
- [ ] KP4 PD 的核心职责（元信息、TSO、调度、均衡）
- [ ] KP5 TiKV 的核心职责（KV / Raft / MVCC / 事务参与者）
- [ ] KP6 TiFlash 的角色（列存副本、MPP、HTAP）
- [ ] KP7 PD 多副本选举与 etcd embedded
- [ ] KP8 TSO 原理与 PD Leader 单点性能上限
- [ ] KP9 Region：96MB 分片、key range、Raft Group
- [ ] KP10 Store 概念，与 TiKV 节点的关系
- [ ] KP11 Leader / Follower / Learner 角色差异与读写路径
- [ ] KP12 计算下推（Coprocessor）原理
- [ ] KP13 gRPC / Protobuf 在组件间通信中的使用
- [ ] KP14 与 MySQL 协议的兼容范围 + 不兼容点
- [ ] KP15 TiDB 版本演进里程碑（1.x → 8.x）

### 动手实验（EX 1–10）

- [ ] EX1 `tiup playground` 启 1+1+1 单机集群
- [ ] EX2 `tiup playground --tiflash` 启 HTAP 集群，验证 TiFlash 同步
- [ ] EX3 编写最小生产拓扑 `topology.yaml`（3 TiKV + 3 PD + 2 TiDB）
- [ ] EX4 `tiup cluster deploy/start/display` 部署 + 查看状态
- [ ] EX5 systemd 自启 + 模拟节点重启，验证自动恢复
- [ ] EX6 TLS：CA / Server / Client 证书签发并部署带 TLS 集群
- [ ] EX7 修改 ports / deploy_dir / data_dir，验证目录结构
- [ ] EX8 部署 Dashboard + Prometheus + Grafana + Alertmanager
- [ ] EX9 `tiup cluster check` 检查 OS / 内核参数（swappiness、ulimit、THP）
- [ ] EX10 `tiup cluster upgrade` 升级到下一补丁版本，观察滚动过程

### 诊断练习（选段）

- [ ] DS26 TiDB Server 502 / 连接拒绝排查
- [ ] DS30 `tiup cluster display` 显示 Down 但进程存活
- [ ] DS32 TiKV 启动报 `cluster id mismatch`

### 关键资源

- 中文文档总览：<https://docs.pingcap.com/zh/tidb/stable/overview>
- 集群部署与配置：<https://docs.pingcap.com/zh/tidb/stable/production-deployment-using-tiup>
- 源码入口阅读：`pingcap/tidb` repo 的 `README.md` + `docs/design/`
- TiDB Internals 论坛架构总览贴：<https://internals.tidb.io>

### 验收清单

1. 能闭卷画出 TiDB / TiKV / PD / TiFlash 的请求路径（含读写）。
2. 解释清楚：Region / Store / Leader / Peer 各自是什么、可不可以一对多。
3. 演示一次完整的 `tiup cluster deploy → start → display → restart → upgrade`。
4. 能口述 PD Leader 切换对集群的影响（TSO、调度、TiDB Server 重连）。

### 阶段复盘（学完后填写）

> 在这里写 200–500 字：什么概念让你"原来如此"了；哪条命令文档讲得不清楚；哪些参数你以前用错了。

---

## 阶段 2：TiKV 存储引擎与 Raft

> 目标：能解释 LSM-Tree 在 TiKV 上的写放大来源；能画出一次 Percolator 两阶段提交的时序；能说出 raftdb 和 kvdb 的区别。
>
> 预估时长：12–15 小时 ｜ 推荐节奏：阅读 5h + 实验 4h + 源码 + 诊断 4h

### 知识点（KP 16–25）

- [ ] KP16 RocksDB：LSM-Tree、CF、Compaction、Bloom Filter
- [ ] KP17 TiKV 双 RocksDB 实例（raftdb / kvdb）
- [ ] KP18 Titan 引擎：大 Value 分离
- [ ] KP19 Raft 核心：选举、复制、提交、安全性
- [ ] KP20 Raft 日志压缩与 Snapshot 机制
- [ ] KP21 MultiRaft + Hibernate Region + Async IO Pool
- [ ] KP22 MVCC 三 CF（Lock / Default / Write）
- [ ] KP23 Percolator 分布式 2PC
- [ ] KP24 Async Commit / 1PC 原理与触发条件
- [ ] KP25 RawKV vs TxnKV 两种 API 模式

### 动手实验

- [ ] EX5 重温：节点重启时观察 Raft Leader 重新选举（已做过可跳过）
- [ ] EX24 `tiup cluster edit-config` 调 `raftstore.apply-pool-size` + reload
- [ ] EX35 `systemctl` kill TiKV 模拟 OOM，观察 Raft 选举
- [ ] EX59 调 `raftstore.store-pool-size` / `apply-pool-size`，观察吞吐
- [ ] EX60 调 `tikv.block-cache.capacity`，对比缓存命中率
- [ ] 自加：用 `tikv-ctl print --key` 查看一行编码后的 row key / index key（与 KP22 配套）
- [ ] 自加：用 `tikv-ctl size` 查看某个 Region 的大小（理解 96MB 默认）

### 诊断练习

- [ ] DS27 TiKV down 后无法上线（raft log 损坏）
- [ ] DS33 TiKV 启动报 `not enough space`（磁盘水位）
- [ ] DS37 TiKV write stall（RocksDB write-buffer/level0 太多）
- [ ] DS38 节点磁盘 IO util 100%
- [ ] DS46 RocksDB sst 损坏，`tikv-ctl recover-mvcc / bad-ssts`
- [ ] DS47 Raft 日志膨胀，`raft-log-gc` 与 compact 配置
- [ ] DS55 大量 `TxnLockNotFound`

### 关键资源

- TiKV 文档：<https://tikv.org/docs/>
- Percolator 论文：<https://research.google/pubs/large-scale-incremental-processing-using-distributed-transactions-and-notifications/>
- Raft 论文：<https://raft.github.io/>
- 源码：`tikv/tikv` repo 的 `components/raftstore/`、`components/server/`、`src/storage/`

### 验收清单

1. 能用一张图讲清楚 TiKV 一次写入从 gRPC 到 Raft commit 再到 RocksDB 落盘的全路径。
2. 解释一次完整的 Percolator 提交（prewrite / commit）涉及哪些 key 操作、哪些 CF。
3. 能复述 Async Commit 触发的两个条件（小事务、单 region）。
4. 能区分 write stall、apply pool full、scheduler full 三类「server is busy」。

### 阶段复盘

> 在这里写：……

---

## 阶段 3：Region 调度与 PD

> 目标：会用 `pd-ctl` 完成日常运维操作；能解释一个 hot region 是怎么被 PD 调走的；会配 Placement Rules。
>
> 预估时长：10–13 小时

### 知识点（KP 26–40）

- [ ] KP26 Coprocessor 表达式 / 聚合 / Limit / TopN 下推
- [ ] KP27 Region 分裂（Split）触发条件与流程
- [ ] KP28 Region 合并（Merge）触发条件
- [ ] KP29 热点 Region 识别机制（hot region scheduler）
- [ ] KP30 Placement Rules：副本数 / 隔离级别 / Label 约束
- [ ] KP31 PD 调度器种类（balance-leader / region / hot / evict）
- [ ] KP32 Operator 与 Step：调度最小单元 + 限流
- [ ] KP33 PD 调度评分模型（region size / leader count / store score）
- [ ] KP34 PD 心跳（store heartbeat / region heartbeat）
- [ ] KP35 PD 元信息持久化 + etcd 角色
- [ ] KP36 Label & Topology / location-labels
- [ ] KP37 Placement Rules in SQL
- [ ] KP38 TiDB Server 中的 Region cache（NotLeader 重定向、backoff）
- [ ] KP39 `pd-ctl` 常用命令（store / region / scheduler / config / cluster）
- [ ] KP40 PD HA：奇数节点 / Leader 切换 / 最小可用节点数

### 动手实验

- [ ] EX21 在线扩容 1 TiKV，观察 PD 自动均衡
- [ ] EX22 在线缩容 1 TiKV，观察 evict-leader + region 迁移
- [ ] EX23 `pd-ctl` 手动切换 PD Leader，观察 TiDB Server 重连
- [ ] EX25 `pd-ctl` 创建 evict-leader-scheduler，模拟 store 离线维护
- [ ] EX26 `pd-ctl region` 查询单 Region 的副本分布、Leader 位置
- [ ] EX27 `pd-ctl operator add transfer-leader` 手动迁移
- [ ] EX28 `store delete` 安全下线 TiKV，验证完成条件
- [ ] EX29 调 `region-schedule-limit` / `leader-schedule-limit` 观察调度速度
- [ ] EX30 Placement Rules 实现跨机房 3-2-1 副本
- [ ] EX31 `ALTER TABLE ... PLACEMENT POLICY` SQL 定义放置策略

### 诊断练习

- [ ] DS16 写热点（自增主键），改 AUTO_RANDOM
- [ ] DS17 读热点，开 Follower Read 缓解
- [ ] DS18 PD Dashboard 显示 hot region 集中，`split region` 手动切分
- [ ] DS19 某 TiKV CPU 飙高，定位单 store 热点 Leader 集中
- [ ] DS20 新表写入全集中一 Region，预切分
- [ ] DS21 时间序列表持续热点：分区 + AUTO_RANDOM
- [ ] DS22 大批量删除导致版本堆积、读热点
- [ ] DS23 队列表（status 字段）热点
- [ ] DS25 Storage capacity unbalanced（label 配置）
- [ ] DS28 PD Leader 频繁切换（网络 / etcd IO）
- [ ] DS29 PD 无法选主，`pd-recover` 流程
- [ ] DS34 PD 报 `region is heartbeat too frequently`
- [ ] DS41 Region 数过多（百万级）：合并空 Region + 调大 region size
- [ ] DS42 Region miss peer（少副本）
- [ ] DS43 Region 有多余副本（extra peer）
- [ ] DS44 Learner 卡住不变 Voter

### 关键资源

- PD 调度文档：<https://docs.pingcap.com/zh/tidb/stable/tidb-scheduling>
- Placement Rules：<https://docs.pingcap.com/zh/tidb/stable/configure-placement-rules>
- 源码：`tikv/pd` repo 的 `server/schedule/`、`server/api/`

### 验收清单

1. 闭卷写出 3 条最常用的 `pd-ctl` 命令并解释参数。
2. 设计一个跨 3 机房 5 副本的 Placement Rule（写出 SQL 或 JSON）。
3. 能讲清楚一个 hot region 从被识别到迁走的完整路径（heartbeat → hot scheduler → operator → step）。

### 阶段复盘

> 在这里写：……

---

## 阶段 4：SQL 引擎与优化器

> 目标：拿到一个慢 SQL 能在 30 分钟内说出 5 个可能的优化方向并验证；会用 SPM 锁计划。
>
> 预估时长：12–15 小时

### 知识点（KP 41–55）

- [ ] KP41 SQL 处理流程（parser → 预处理 → 逻辑优化 → 物理优化 → 执行）
- [ ] KP42 AST 与 Plan Tree（plannercore 的 Logical/Physical 转换）
- [ ] KP43 CBO：Statistics、直方图、Count-Min Sketch、TopN
- [ ] KP44 ANALYZE TABLE、auto-analyze、Feedback
- [ ] KP45 火山模型 + 向量化执行（chunk-based）
- [ ] KP46 SQL Hint：`/*+ HASH_JOIN(t1) */` 等
- [ ] KP47 SPM：BINDING、auto capture
- [ ] KP48 索引类型（唯一、联合、表达式、不可见、聚簇）
- [ ] KP49 聚簇表 vs 非聚簇表、`_tidb_rowid`
- [ ] KP50 AUTO_INCREMENT vs AUTO_RANDOM 高并发分配
- [ ] KP51 View / Sequence / TTL Table / 分区表基础
- [ ] KP52 分区表（Range / Hash / List / Range Columns / Key）内部实现
- [ ] KP53 临时表（Local / Global Temporary Table）
- [ ] KP54 EXPLAIN / EXPLAIN ANALYZE / EXPLAIN FOR CONNECTION
- [ ] KP55 慢日志 + `tidb_slow_query` 表 + expensive query 阈值

### 动手实验

- [ ] EX11 聚簇 / 非聚簇表对比 EXPLAIN 与 `_tidb_rowid`
- [ ] EX12 AUTO_RANDOM 高并发写入热点缓解
- [ ] EX13 Range / Hash / List 分区表 + `SHOW TABLE STATUS`
- [ ] EX14 EXPLAIN ANALYZE 全表扫 → 改索引访问
- [ ] EX15 联合索引设计 + 命中前后对比
- [ ] EX16 ANALYZE TABLE + `SHOW STATS_META / STATS_HISTOGRAMS`
- [ ] EX17 SQL Binding 固化 Hash Join
- [ ] EX18 GLOBAL TEMPORARY TABLE 多会话不共享验证
- [ ] EX19 TTL TABLE 自动清理验证
- [ ] EX20 子查询 / 窗口 / CTE 复杂 SQL 计划对比

### 诊断练习

- [ ] DS1 统计信息过期导致 SQL 变慢，`SHOW STATS_HEALTHY`
- [ ] DS2 走错索引，USE / FORCE / SPM 修正
- [ ] DS3 全表扫定位缺失索引
- [ ] DS4 不同 TiDB Server 计划不一致，Plan Cache + Hint
- [ ] DS5 cop_task 慢，定位 Coprocessor 慢 Region
- [ ] DS6 Selection 下推失败（"not pushed down"）
- [ ] DS7 JOIN 顺序不合理，LEADING / STRAIGHT_JOIN 修正
- [ ] DS8 Hash Join build 端选错
- [ ] DS9 limit/offset 大偏移，keyset pagination
- [ ] DS10 ORDER BY + LIMIT 未走索引
- [ ] DS11 IN (...) 过大，改临时表 join
- [ ] DS12 Plan Cache 命中率低
- [ ] DS13 大量慢 SQL，digest 聚合分析
- [ ] DS14 同一 SQL 不同时段计划不同（auto-analyze 抖动）
- [ ] DS15 视图嵌套 / CTE 物化策略 → `MATERIALIZE` Hint

### 关键资源

- 优化器系列文档：<https://docs.pingcap.com/zh/tidb/stable/sql-optimization-concepts>
- SQL Hint 列表：<https://docs.pingcap.com/zh/tidb/stable/optimizer-hints>
- 源码：`pingcap/tidb` repo 的 `pkg/parser/`、`pkg/planner/`、`pkg/executor/`

### 验收清单

1. 拿一个新的慢 SQL，10 分钟内输出 EXPLAIN + 至少 3 个改写方向。
2. 能解释一次 Plan Cache 命中失败的常见原因（参数化、Hint、Schema 变化）。
3. 用 SPM BINDING 锁住一个执行计划，并演示如何升级版本后回看是否生效。

### 阶段复盘

> 在这里写：……

---

## 阶段 5：分布式事务与一致性

> 目标：能说清乐观 vs 悲观的成本与适用场景；理解 GC safe point 推不动的根因。
>
> 预估时长：8–10 小时

### 知识点（KP 56–65）

- [ ] KP56 乐观 vs 悲观事务模型
- [ ] KP57 悲观事务加锁（in-memory pessimistic lock、async lock）
- [ ] KP58 隔离级别：RR 实为 Snapshot Isolation
- [ ] KP59 `tidb_txn_mode`、`tidb_skip_isolation_level_check`
- [ ] KP60 大事务限制：`txn-total-size-limit` / `txn-entry-size-limit`
- [ ] KP61 自动重试（`tidb_disable_txn_auto_retry`）
- [ ] KP62 Read Committed 与 MySQL 差异
- [ ] KP63 分布式死锁检测、`INFORMATION_SCHEMA.DEADLOCKS`
- [ ] KP64 Stale Read / Follower Read / Read Replica Scaling
- [ ] KP65 CDC 一致性：TiCDC changefeed + commit_ts 排序

### 动手实验

- [ ] EX56 启 Follower Read，对比 Leader Read 延迟
- [ ] EX57 启 Stale Read（`tidb_read_staleness = -5`）
- [ ] EX58 Async Commit / 1PC 开启前后 commit 延迟差异
- [ ] EX93 调 `tidb_gc_life_time`，对比对长事务影响
- [ ] EX96 跨 region 大事务，观察 1PC / Async Commit 触发情况

### 诊断练习

- [ ] DS55 `TxnLockNotFound`（与阶段 2 重叠，深读一次）
- [ ] DS56 `transaction too large`
- [ ] DS57 频繁 write conflict
- [ ] DS58 死锁分析（DEADLOCKS 表 + 锁等待图）
- [ ] DS59 长事务阻塞 GC，safe point 推不动
- [ ] DS60 悲观锁等待超时
- [ ] DS61 异步提交一致性（min-commit-ts、max-ts）
- [ ] DS62 GC 卡住排查
- [ ] DS63 读卡在 lock，触发 resolve lock
- [ ] DS64 多语句事务被 KILL
- [ ] DS65 AUTO_INCREMENT 跳号

### 关键资源

- 事务模型对比：<https://docs.pingcap.com/zh/tidb/stable/transaction-overview>
- Async Commit 设计文档：搜索 `pingcap/tidb` repo 的 `docs/design/2020-01-10-async-commit.md`

### 验收清单

1. 写一个 100 行的写冲突复现脚本，乐观下报错、悲观下排队，并讲清两者代价。
2. 解释 GC safe point 是怎么被一个长事务卡住的，以及如何排查源头。

### 阶段复盘

> 在这里写：……

---

## 阶段 6：HTAP 与 TiFlash

> 目标：能判断一条 SQL 该走 TiKV 还是 TiFlash；能给 TiFlash OOM 给出 3 个降级方案。
>
> 预估时长：10–12 小时

### 知识点（KP 66–75）

- [ ] KP66 TiFlash 列存模型（DeltaTree）vs TiKV
- [ ] KP67 TiFlash 与 TiKV 同步：Raft Learner + Region snapshot
- [ ] KP68 TiFlash 写入：Delta Layer / Stable Layer / Compaction
- [ ] KP69 MPP 模式：Exchange / Broadcast / HashPartition Sender / Plan Fragment
- [ ] KP70 Optimizer 在 TiKV / TiFlash 间的物理表选择
- [ ] KP71 `ALTER TABLE ... SET TIFLASH REPLICA` 用法
- [ ] KP72 TiFlash 资源隔离（`tiflash_mem_quota`、`tiflash_max_threads`）
- [ ] KP73 列存索引（ColumnarIndex / Lucene 等新功能）
- [ ] KP74 TiFlash 异常副本恢复与重建
- [ ] KP75 HTAP 适用场景与限制

### 动手实验

- [ ] EX2 重温：`tiup playground --tiflash` 集群
- [ ] EX66 表 `SET TIFLASH REPLICA 2`，观察同步进度
- [ ] EX67 TiFlash 上跑聚合 SQL，TiKV vs TiFlash 路径耗时对比
- [ ] EX68 `tidb_allow_mpp = ON`，观察 ExchangeSender/Receiver
- [ ] EX69 TPC-H Q1 / Q5 / Q9 在 TiFlash 跑
- [ ] EX70 模拟 TiFlash 宕机，副本恢复 + 自动回退
- [ ] EX71 `tiflash-ctl` 查 region 同步与状态
- [ ] EX72 禁用 TiFlash 副本，SQL 自动改走 TiKV
- [ ] EX73 `tidb_isolation_read_engines` 在线切换
- [ ] EX74 调 `max_threads` / `mem_quota` 对比并发
- [ ] EX75 列存索引检索实验

### 诊断练习

- [ ] DS24 TiFlash 单节点 CPU 高（MPP 数据倾斜）
- [ ] DS66 TiFlash 副本长期不可用
- [ ] DS67 TiFlash 查询比 TiKV 还慢
- [ ] DS68 MPP 计划未生效
- [ ] DS69 TiFlash OOM
- [ ] DS70 TiFlash 写入延迟高
- [ ] DS71 TiFlash 分裂同步异常
- [ ] DS72 TiFlash 节点 hot region 集中
- [ ] DS73 CDC 与 TiFlash 同步时延差异
- [ ] DS74 `SET TIFLASH REPLICA 0` 后磁盘未释放
- [ ] DS75 TiFlash 节点磁盘满

### 关键资源

- TiFlash 文档：<https://docs.pingcap.com/zh/tidb/stable/tiflash-overview>
- MPP 模式说明：<https://docs.pingcap.com/zh/tidb/stable/use-tiflash-mpp-mode>
- 源码：`pingcap/tiflash` repo（注意是独立 repo）

### 验收清单

1. 给定一张表 + 3 条 SQL，正确判断哪些应走 TiFlash、为什么。
2. 演示一次完整的「加 TiFlash 副本 → 同步进度 → 切换查询引擎 → 删除副本」流程。

### 阶段复盘

> 在这里写：……

---

## 阶段 7：生态工具与数据迁移

> 目标：能独立完成一次 MySQL → TiDB 全量+增量迁移，并校验一致性。
>
> 预估时长：12–15 小时

### 知识点（KP 76–85）

- [ ] KP76 TiUP 全家桶（cluster / playground / dm）
- [ ] KP77 TiUP cluster 操作模型（topology / meta / 命令）
- [ ] KP78 BR：基于 SST 的物理备份
- [ ] KP79 Dumpling：逻辑导出
- [ ] KP80 TiDB Lightning：local / tidb backend、physical / logical 模式
- [ ] KP81 DM：MySQL → TiDB 全量+增量、shard merge
- [ ] KP82 TiCDC：捕获 change log → Kafka / MySQL / S3 / Pulsar
- [ ] KP83 sync-diff-inspector：上下游一致性
- [ ] KP84 PCP / Prometheus / Grafana / Dashboard 监控生态
- [ ] KP85 TiSpark / Flink Connector

### 动手实验

- [ ] EX36 BR 全量备份到本地
- [ ] EX37 BR 备份到对象存储（S3/GCS/OSS）
- [ ] EX38 BR restore 到新集群 + 一致性校验
- [ ] EX39 BR 日志备份（PITR）+ 时间点恢复
- [ ] EX40 Dumpling 导出 csv（where / 过滤 / 并发参数）
- [ ] EX41 Lightning local backend 导入 1000 万行
- [ ] EX42 Lightning tidb backend 导入 + 业务集群影响观察
- [ ] EX43 DM：source.yaml + task.yaml 同步 MySQL → TiDB
- [ ] EX44 DM 分库分表合并（shard merge）
- [ ] EX45 DM 断点续传：kill worker → checkpoint 恢复
- [ ] EX46 TiCDC 同步 TiDB → Kafka（canal-json）
- [ ] EX47 TiCDC 同步到下游 MySQL + sync-diff-inspector 校验
- [ ] EX48 sync-diff-inspector 修复不一致
- [ ] EX49 BR + TiCDC 组合：全量+增量迁移演练
- [ ] EX50 跨版本数据迁移：6.5 LTS → 7.5 LTS

### 诊断练习

- [ ] DS76 DM GTID 丢失，全量重做
- [ ] DS77 DM 字符集不兼容
- [ ] DS78 DM 重复 key
- [ ] DS79 TiCDC changefeed lag 持续增长
- [ ] DS80 TiCDC `event size too large`
- [ ] DS81 TiCDC 与 TiKV GC 冲突（safe-point 被拉住）
- [ ] DS82 Lightning checksum 不一致
- [ ] DS83 Lightning local backend 与业务集群共用问题
- [ ] DS84 BR 备份失败（S3 权限 / 网络 / Region scatter）
- [ ] DS85 sync-diff-inspector 数据不一致定位

### 关键资源

- 数据迁移概览：<https://docs.pingcap.com/zh/tidb/stable/migration-overview>
- BR 文档：<https://docs.pingcap.com/zh/tidb/stable/backup-and-restore-overview>
- TiCDC 文档：<https://docs.pingcap.com/zh/tidb/stable/ticdc-overview>

### 验收清单

1. 独立完成一次「MySQL 全量 Dumpling → Lightning 导入 → DM 增量 → sync-diff 校验」端到端演练。
2. 能讲清 BR、Dumpling、Lightning 三个工具各自适合的场景。

### 阶段复盘

> 在这里写：……

---

## 阶段 8：性能压测与调优

> 目标：建立自己的 TiDB 性能调优 SOP；能用 sysbench + go-tpc 做基线对比。
>
> 预估时长：12–15 小时

### 知识点回顾

- [ ] 重读 KP43–47（CBO、SPM、统计信息、向量化）
- [ ] 重读 KP7–8（TSO 单点性能上限）
- [ ] 重读 KP59–60（事务相关变量）

### 动手实验（EX 51–65）

- [ ] EX51 sysbench oltp_point_select 点查 QPS
- [ ] EX52 sysbench oltp_read_write 混合负载
- [ ] EX53 go-tpc TPC-C，tpmC + 延迟分布
- [ ] EX54 go-tpc TPC-H，TiFlash MPP 加速比
- [ ] EX55 调 `tidb_distsql_scan_concurrency` / `tidb_index_lookup_concurrency`
- [ ] EX56 Follower Read 对比（如阶段 5 已做可复用）
- [ ] EX57 Stale Read 对比（同上）
- [ ] EX58 Async Commit / 1PC 对比（同上）
- [ ] EX59 调 raftstore pool（与阶段 2 重叠）
- [ ] EX60 调 block-cache.capacity（与阶段 2 重叠）
- [ ] EX61 写热点：SHARD_ROW_ID_BITS / AUTO_RANDOM
- [ ] EX62 EXPLAIN ANALYZE + Top SQL 找最耗 CPU 的 SQL 改写
- [ ] EX63 Continuous Profiling 抓火焰图定位 TiKV 热点
- [ ] EX64 Resource Control：多 Resource Group 限制低优组 RU
- [ ] EX65 突发流量观察 Resource Group 限流与排队

### 诊断练习（DS 86–100）

- [ ] DS86 CPU 高 QPS 低（raftstore vs unified read pool）
- [ ] DS87 磁盘 IO 高，拆分 compaction / write 路径
- [ ] DS88 网络带宽打满（region snapshot vs 业务）
- [ ] DS89 TiDB Server 内存增长（计划缓存、prepare 泄漏）
- [ ] DS90 TiKV unified-read-pool 不足
- [ ] DS91 coprocessor request 排队
- [ ] DS92 region cache 老化频繁
- [ ] DS93 PD operator pending 过多
- [ ] DS94 突发请求触发 `server is busy`
- [ ] DS95 应用连接数飙高，连接池 / 中间件 / 限流
- [ ] DS96 整库迁移后性能下降（统计信息、热数据）
- [ ] DS97 升级后某些 SQL 变慢，SPM 锁旧计划
- [ ] DS98 空载下持续 CPU 1 核（compact / gc / stats）
- [ ] DS99 大量短连接，HAProxy timeout + token-limit
- [ ] DS100 `ER_NET_PACKET_TOO_LARGE` / read timeout

### 关键资源

- 性能调优总览：<https://docs.pingcap.com/zh/tidb/stable/tidb-tuning-overview>
- Resource Control：<https://docs.pingcap.com/zh/tidb/stable/tidb-resource-control>

### 验收清单

1. 写一份「TiDB 性能问题 5 步排查 SOP」（监控视角、SQL 视角、节点视角、Raft 视角、GC 视角）。
2. 用 sysbench / go-tpc 跑基线，并把结果与默认参数下的对比记录成表。

### 阶段复盘

> 在这里写：……

---

## 阶段 9：运维监控告警与高可用

> 目标：拿一个集群能在 30 分钟内输出健康巡检报告 + 关键告警阈值清单。
>
> 预估时长：10–12 小时

### 知识点（KP 86–95）

- [ ] KP86 部署拓扑：最小生产、跨 AZ、跨地域多活
- [ ] KP87 滚动升级：tiup cluster upgrade + 灰度 + 回滚
- [ ] KP88 在线扩缩容对 PD 调度的影响
- [ ] KP89 关键监控指标
- [ ] KP90 Alert Rules（磁盘 / Raftstore CPU / TiKV channel full / PD operator pending）
- [ ] KP91 集群健康检查（`tiup cluster check / display / status`）
- [ ] KP92 TiDB Dashboard（Key Visualizer / Top SQL / 慢查询）
- [ ] KP93 Continuous Profiling
- [ ] KP94 滚动重启与维护窗口
- [ ] KP95 高可用：3/5 TiKV + 跨机房 + Placement Rules

### 动手实验（EX 76–85）

- [ ] EX76 Grafana 看 TiKV Raft / Coprocessor / Thread CPU 面板
- [ ] EX77 Key Visualizer 找写热点 Region
- [ ] EX78 Top SQL 找 CPU 占比最大的 SQL
- [ ] EX79 Slow Query 按 digest 聚合
- [ ] EX80 Continuous Profiling 抓 TiDB / TiKV / PD 火焰图
- [ ] EX81 Alertmanager Webhook → 企微 / 钉钉 / 飞书
- [ ] EX82 自定义 Prometheus Recording / Alert Rules
- [ ] EX83 INFORMATION_SCHEMA.CLUSTER_* / STATEMENTS_SUMMARY 诊断
- [ ] EX84 SHOW PROCESSLIST + KILL TIDB
- [ ] EX85 模拟磁盘满，观察 PD evict-leader
- [ ] EX32 升级 TiUP 自身：`tiup update --self / --all`
- [ ] EX33 自定义 grafana_user 密码并 reload 监控
- [ ] EX34 增加 TiDB Server 节点，HAProxy / ProxySQL 后端做负载均衡

### 诊断练习（补漏）

- [ ] DS31 滚动升级卡住，evict-leader-scheduler 残留
- [ ] DS35 `region unavailable`，定位 Raft 状况
- [ ] DS36 `TiKV server is busy`（scheduler full / write stall）
- [ ] DS39 TiKV channel full（apply / store pool 不足）
- [ ] DS40 重启后 region 长期未恢复 leader
- [ ] DS45 Stale region cache → NotLeader
- [ ] DS48 TiKV 内存使用过高（block cache / write buffer / coprocessor）
- [ ] DS49 大 Key / 大 Value
- [ ] DS50 Region split 失败
- [ ] DS51 Region merge 后访问异常
- [ ] DS52 单机多盘 data-dir / raftdb-path 分离
- [ ] DS53 NVMe / SSD 性能下降，fsync 监控
- [ ] DS54 `tikv-ctl print` 查 key 编码

### 关键资源

- 监控指标列表：<https://docs.pingcap.com/zh/tidb/stable/grafana-overview-dashboard>
- Dashboard 用户指南：<https://docs.pingcap.com/zh/tidb/stable/dashboard-overview>

### 验收清单

1. 自己整理一份「巡检 Checklist」（节点、PD、TiKV、TiDB、Grafana、Dashboard 各一节）。
2. 写一份 Top 10 告警规则的 YAML，每条带阈值 + 处理动作。

### 阶段复盘

> 在这里写：……

---

## 阶段 10：安全、新特性、综合故障演练

> 目标：完成 5 个真实生产可能遇到的灾备 / 安全场景演练；输出最终复盘。
>
> 预估时长：10–12 小时

### 知识点（KP 96–100）

- [ ] KP96 用户与权限、TLS、SSL 客户端证书
- [ ] KP97 Resource Control / Resource Group / RU
- [ ] KP98 TiDB Serverless / Cloud Dedicated 运维差异
- [ ] KP99 TDE 透明数据加密 / KMS
- [ ] KP100 新特性追踪：Fast DDL / Index Merge / 向量索引 / Cascades

### 动手实验（EX 86–100）

- [ ] EX86 模拟 PD 1 节点宕机，验证 TSO 服务恢复时长
- [ ] EX87 模拟 TiKV 整机宕机
- [ ] EX88 模拟整机房断电（多副本）
- [ ] EX89 升级失败回滚演练
- [ ] EX90 `tikv-ctl unsafe-recover remove-fail-stores`
- [ ] EX91 `pd-recover` 重建 PD
- [ ] EX92 在线增加 TiFlash 节点 + 平衡列存副本
- [ ] EX93 调 GC life time（复用）
- [ ] EX94 `ADMIN CHECK TABLE` 校验索引与数据一致性
- [ ] EX95 `ADMIN SHOW DDL` / `CANCEL DDL JOB`
- [ ] EX96 跨 region 大事务（复用）
- [ ] EX97 cgroup / docker 限制 TiKV 资源，复现资源不足故障
- [ ] EX98 TLS 双向认证 + mysql client 证书连接
- [ ] EX99 OLTP / BI 报表分别设置 Resource Group 基线
- [ ] EX100 编写一键巡检脚本

### 关键资源

- 灾备最佳实践：<https://docs.pingcap.com/zh/tidb/stable/three-data-centers-in-two-cities-deployment>
- TiDB 新特性列表（每次升级前看）：<https://docs.pingcap.com/zh/tidb/stable/release-notes>

### 验收清单

1. 完成 5 个故障演练（自选）+ 每个写 200 字复盘。
2. 一键巡检脚本能跑出节点 / Region / SQL / GC / 备份 5 类指标的健康度。
3. 写出你下一步想深入的 1–2 个方向（比如 Cascades planner、向量索引、Serverless 运营）。

### 最终复盘

> 在这里写 500–1000 字：通读 100+100+100 之后，什么是你之前**最常用但理解最浅**的部分；哪些是你以前**根本没意识到存在**的部分。

---

## 碎片时间使用模板

| 场景 | 时长 | 推荐动作 |
| --- | --- | --- |
| 通勤 / 排队 | 15–20 min | 读 2–3 个 KP，记在手机备忘录里 |
| 午休 | 30–45 min | 看官方文档对应小节 + 在测试集群 SHOW VARIABLES |
| 晚上整段 | 1–2 h | 跑 1 个 EX，截图 Grafana 关键面板 |
| 周末上午 | 2–3 h | 复现 1–2 个 DS，写复盘 |
| 周末下午 | 2–3 h | 通读源码 / 看 internals 论坛长帖 |

---

## 阶段复盘模板（每阶段末尾用）

```
# 阶段 X 复盘

## 已完成 checklist
- [x] KP …
- [x] EX …
- [x] DS …

## 三个反直觉的发现
1.
2.
3.

## 留坑 / 下阶段要回头补的
- [ ]
- [ ]

## 关键截图 / 命令
（粘贴 Grafana 图、pd-ctl 输出等）
```

---

## 第 1 周（阶段 1）详细日程参考

> 假设每周可用：通勤 5 段 × 20 min + 工作日晚上 2 段 × 1.5 h + 周末 1 段 × 3 h ≈ 8.5 h。可按实际拉伸。

| 时段 | 时长 | 任务 |
| --- | --- | --- |
| Day 1 通勤 | 20 min | KP1、KP2 通读 |
| Day 1 晚上 | 1.5 h | EX1 `tiup playground` 跑通 + 截图组件状态 |
| Day 2 通勤 | 20 min | KP3、KP4 通读 |
| Day 2 晚上 | 1.5 h | EX2 + EX3 拓扑文件草稿 |
| Day 3 通勤 | 20 min | KP5、KP6、KP7 |
| Day 3 晚上 | — | 缓冲 / 看官方文档 overview |
| Day 4 通勤 | 20 min | KP8、KP9、KP10 |
| Day 4 晚上 | 1.5 h | EX4 + EX5（部署 + 重启验证） |
| Day 5 通勤 | 20 min | KP11、KP12、KP13 |
| Day 5 晚上 | — | 缓冲 |
| 周末上午 | 3 h | EX6（TLS 部署）+ EX8（监控套件） |
| 周末下午 | — | 留给阶段复盘 + DS26/30/32 三个诊断练习 |

---

> 这份周计划是骨架，跑起来后**鼓励你随时改它**：把已掌握的项标注 ✅、把卡住的项写上「为什么卡住」、新发现的实验追加到对应阶段。学习计划本身的迭代，就是学习的一部分。
