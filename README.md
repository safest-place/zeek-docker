# 定制备注

## 脚本文件定制

### site/local.zeek

redef Analyzer::disable_all = T;
禁用所有协议分析器

redef LogAscii::json_timestamps = JSON::TS_MILLIS;
json日志使用毫秒时间戳，参考文档：https://docs.zeek.org/en/master/scripts/base/init-bare.zeek.html#type-JSON::TimestampFormat

redef LogAscii::use_json = T;
日志格式改为JSON

redef Log::default_scope_sep = "_";
JSON中字段的分隔符从.修改为“ _ ”

redef Log::default_field_name_map = {
["service"] = "_service"
};
service与thrift中关键字冲突，替换成_service

@load frameworks/telemetry/prometheus
启用prometheus监控指标，默认监听9911端口

### site/ja3/__load__.zeek

ja3脚本默认启用intel框架，导致启动zeek失败，暂时用不到intel框架，就直接禁用了

### protocols/mysql/dpd.sig

zeek 缺少mysql指纹，通过这个文件补充

### protocols/mysql/__load__.zeek

通过这个文件加载mysql指纹

### capture-loss.zeek

修改了这个文件内容采集capture_loss的百分比指标
新增全局变量：

```shell
global capture_loss_pct = Telemetry::register_gauge_family([
        $prefix = "zeek",
        $name = "capture-loss-pct",
        $unit="1",
        $help_text="Percentage of ACKs seen where the data being ACKed wasn't seen.",
]);

global no_labels: vector of string;
global pct_lost_gf: double;
```

在计算百分比并存储到capture_loss.log时，获取百分比的变量赋值给全局变量

```shell
event CaptureLoss::take_measurement(last_ts: time, last_acks: count, last_gaps: count)
        {
        ************
       pct_lost_gf = info$percent_lost;
       ************
       }
```

将采集到的指标发送给manager

```shell
hook Telemetry::sync()
{
        if ( reading_live_traffic() )
        {
                Telemetry::gauge_family_set(capture_loss_pct, no_labels, pct_lost_gf);
        }
}
```

