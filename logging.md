# Logging guidelines

All services should log in json format, with relevant id's as tags (incidentId, missionId, responderId...).
The logs should be collected by fluentd and aggregated/indexed in ElasticSearch

Logging will be handled by net.logstash.logback.encoder.LogstashEncoder. This contains only subset of the documentation 
for a quick start. See [documentation](https://github.com/logstash/logstash-logback-encoder) for full documentation.

## Tips and best practices

Object construction is costly. Therefore, it is best practice to surround the log lines with logger.isXXXEnabled(),
 to avoid the object construction if the log level is disabled. But do that only for Debug and trace level logging, info 
 is the lowest level in production anyways.
 
 You can create a logback-test.xml to src/test/resources and have a "normal" logging there for your unit tests.

## Maven dependency 

```xml
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>6.3</version>
</dependency>
```

## Example logback.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

    <appender name="STDOUT-JSON" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder">
            <customFields>{"application":"incident-service", "er-demo":"yes"}</customFields>
            <fieldNames>
                <timestamp>timestamp</timestamp>
                <version>log-version</version>
            </fieldNames>
        </encoder>
    </appender>

    <logger name="com.redhat.cajun.navy.incident" level="INFO"/>

    <root level="INFO">
        <appender-ref ref="STDOUT"/>
    </root>

</configuration>

```

Due to the reactive nature of majority of the services do not use Mapped Diagnostic Context (MDC) but
 [StructuredArguments](https://github.com/logstash/logstash-logback-encoder#event-specific-custom-fields) 

## Log format fields

| Field       | Mandatory     | Description     | Example value |
| :-------------: | :----------: | :-----------: | :-----------: |
| timestamp | y | Time when event happened    | 2020-01-10T14:38:09.431+02:00|
| log-version| y | Log entry version | 1 |
| message | y | Actual log entry | Sent 'IncidentReportedEvent' message for incident identifier=672dfb8b-17e7-4bd3-a702-2963df3fdb05 |
| logger_name | y | Logger name | com.redhat.cajun.navy.incident.service.IncidentService |
| thread_name | n | Thread that wrote the entry  | kafka-producer-network-thread   | producer-1 |
| level | y | Log level | DEBUG |
| level_value | n | ? | 10000 |
| incidentId | y? | Incident identifier | 672dfb8b-17e7-4bd3-a702-2963df3fdb05 |
| missionId  | n? | Mission identifier  | ? |
| responderId | n? | Responder identifier | ? |
| application | y | Application identifier | incident-service |
| er-demo | y | Groups all er-demo logs | yes |
| stack_trace | n | Shows stacktrace if Throwable found | ... |

## Possible fields to add and other questions

### Should buildinfo be added to log entries?

"buildinfo":{"version":"Version 0.1.0-SNAPSHOT","lastcommit":"75473700d5befa953c45f630c6d9105413c16fe1"}

### Should log timestamps use UTC as only timezone?

```xml
<timeZone>UTC</timeZone>
``` 
 
## Log format example

Example of a log entry without a throwable:

```json
{
    "timestamp": "2020-01-10T14:38:09.431+02:00",
    "log-version": "1",
    "message": "Sent 'IncidentReportedEvent' message for incident identifier=672dfb8b-17e7-4bd3-a702-2963df3fdb05",
    "logger_name": "com.redhat.cajun.navy.incident.service.IncidentService",
    "thread_name": "kafka-producer-network-thread | producer-1",
    "level": "DEBUG",
    "level_value": 10000,
    "incidentId": "672dfb8b-17e7-4bd3-a702-2963df3fdb05",
    "application": "incident-service",
    "er-demo": "yes"
}
``` 
          
Example of a log entry with throwable:

```json
{
    "timestamp": "2020-01-11T14:34:11.156+02:00",
    "log-version": "1",
    "message": "Error sending 'IncidentReportedEvent' message for incident incidentId=27539c55-e5ba-4a5e-800d-3cb669056932 ",
    "logger_name": "com.redhat.cajun.navy.incident.service.IncidentService",
    "thread_name": "main",
    "level": "ERROR",
    "level_value": 40000,
    "stack_trace": "java.util.concurrent.CancellationException: nulln\tat java.util.concurrent.FutureTask.report(FutureTask.java:121)\n\tat java.util.concurrent.FutureTask.get(FutureTask.java:192)\n\tat org.springframework.util.concurrent.ListenableFutureTask.done(ListenableFutureTask.java:83)\n\tat org.springframework.util.concurrent.SettableListenableFuture$SettableTask.done(SettableListenableFuture.java:175)\n\tat java.util.concurrent.FutureTask.finishCompletion(FutureTask.java:384)\n\tat java.util.concurrent.FutureTask.cancel(FutureTask.java:180)\n\tat org.springframework.util.concurrent.SettableListenableFuture.cancel(SettableListenableFuture.java:92)\n\tat com.redhat.cajun.navy.incident.service.IncidentServiceTest.init(IncidentServiceTest.java:82)\n\tat sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)\n\tat sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)\n\tat sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)\n\tat java.lang.reflect.Method.invoke(Method.java:498)\n\tat org.junit.runners.model.FrameworkMethod$1.runReflectiveCall(FrameworkMethod.java:50)\n\tat org.junit.internal.runners.model.ReflectiveCallable.run(ReflectiveCallable.java:12)\n\tat org.junit.runners.model.FrameworkMethod.invokeExplosively(FrameworkMethod.java:47)\n\tat org.junit.internal.runners.statements.RunBefores.evaluate(RunBefores.java:24)\n\tat org.junit.runners.ParentRunner.runLeaf(ParentRunner.java:325)\n\tat org.junit.runners.BlockJUnit4ClassRunner.runChild(BlockJUnit4ClassRunner.java:78)\n\tat org.junit.runners.BlockJUnit4ClassRunner.runChild(BlockJUnit4ClassRunner.java:57)\n\tat org.junit.runners.ParentRunner$3.run(ParentRunner.java:290)\n\tat org.junit.runners.ParentRunner$1.schedule(ParentRunner.java:71)\n\tat org.junit.runners.ParentRunner.runChildren(ParentRunner.java:288)\n\tat org.junit.runners.ParentRunner.access$000(ParentRunner.java:58)\n\tat org.junit.runners.ParentRunner$2.evaluate(ParentRunner.java:268)\n\tat org.junit.runners.ParentRunner.run(ParentRunner.java:363)\n\tat org.junit.runner.JUnitCore.run(JUnitCore.java:137)\n\tat com.intellij.junit4.JUnit4IdeaTestRunner.startRunnerWithArgs(JUnit4IdeaTestRunner.java:68)\n\tat com.intellij.rt.junit.IdeaTestRunner$Repeater.startRunnerWithArgs(IdeaTestRunner.java:33)\n\tat com.intellij.rt.junit.JUnitStarter.prepareStreamsAndStart(JUnitStarter.java:230)\n\tat co",
    "incidentId": "27539c55-e5ba-4a5e-800d-3cb669056932",
    "application": "incident-service",
    "er-demo": "yes"
}
```
