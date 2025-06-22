# Project 4: Monitoring and Observability

Set up comprehensive monitoring for your applications using Prometheus and Grafana.

---

## What This Creates

* **Prometheus**: Collects metrics from applications and infrastructure
* **Grafana**: Creates beautiful dashboards and alerts
* **Node Exporter**: System metrics (CPU, memory, disk)
* **cAdvisor**: Container metrics
* **AlertManager**: Handles and routes alerts
* **Custom dashboards**: For your web applications

---

## Architecture

```
Your App → Prometheus → Grafana → Beautiful Dashboards
↓           ↓           ↓
System Metrics → Alerts → Notifications
```

---

## Prerequisites

* [Docker Desktop](https://www.docker.com/products/docker-desktop)
* Your web application from previous projects (optional)
* Web browser

---

## Step-by-Step Setup

### 1. Start the Monitoring Stack

```bash
# Start all monitoring services
docker-compose up -d

# Check all services are running
docker-compose ps
```

You should see services on the following ports:

* Prometheus: `9090`
* Grafana: `3000`
* Node Exporter: `9100`
* cAdvisor: `8080`
* Alertmanager: `9093`

---

### 2. Access the Tools

* **Prometheus (Metrics Database)**: [http://localhost:9090](http://localhost:9090)

  * Check targets: `Status` → `Targets`
  * Try query: `up`

* **Grafana (Dashboards)**: [http://localhost:3000](http://localhost:3000)

  * Login: `admin` / `admin`
  * Explore interface

* **Node Exporter**: [http://localhost:9100/metrics](http://localhost:9100/metrics)

* **cAdvisor**: [http://localhost:8080](http://localhost:8080)

---

### 3. Configure Grafana Data Source

1. In Grafana, go to **Settings (Gear icon) → Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. Set URL to `http://prometheus:9090`
5. Click **Save & Test**

---

### 4. Create Your First Dashboard

**Option 1: Import Pre-built Dashboard**

```text
- Click "+" → "Import"
- Enter Dashboard ID: 1860 (Node Exporter Full)
- Select Prometheus as data source
- Click "Import"
```

**Option 2: Create Custom Dashboard**

1. Click `+` → `Dashboard`
2. Add a panel and select the Prometheus data source
3. Enter query: `up`
4. Click `Apply` and `Save`

---

### 5. Monitor Your Web Application

```bash
# From Project 2:
cd ../project-2-cicd-pipeline
npm start
```

* Visit Prometheus Targets: [http://localhost:9090/targets](http://localhost:9090/targets)
* Create a dashboard using `webapp-dashboard.json` or build custom panels

---

### 6. Set Up Alerts (Optional)

Create `alert_rules.yml`:

```yaml
groups:
  - name: webapp_alerts
    rules:
      - alert: WebAppDown
        expr: up{job="my-webapp-local"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Web application is down"
          description: "The web application has been down for more than 1 minute."

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 2 minutes."
```

---

### 7. Explore Useful Metrics

**System Metrics**

* `node_cpu_seconds_total` – CPU usage
* `node_memory_MemAvailable_bytes` – Available memory
* `node_filesystem_free_bytes` – Disk space

**Container Metrics**

* `container_cpu_usage_seconds_total`
* `container_memory_usage_bytes`
* `container_network_receive_bytes_total`

**App Metrics (if instrumented)**

* `http_requests_total` – Total requests
* `http_request_duration_seconds` – Latency
* `process_cpu_seconds_total` – App CPU

---

## AWS Integration (Optional)

### Monitor ECS Services

```bash
kubectl apply -f aws-cloudwatch-integration.yml
```

* Update Prometheus config
* Import ECS-related dashboards: CPU, memory, task count, ALB metrics

### Monitor Kubernetes

```bash
kubectl apply -f https://github.com/kubernetes/kube-state-metrics/examples/standard
```

* Import dashboards:

  * ID 315: Kubernetes cluster
  * ID 8588: Deployment metrics

---

## Common PromQL Queries

**CPU Usage**

```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100)
```

**Memory Usage**

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**App Uptime**

```promql
up{job="my-webapp-local"}
```

---

## Troubleshooting

### Services Not Starting

```bash
docker-compose logs prometheus
docker-compose restart
docker-compose ps
```

### No Data in Grafana

* Verify Prometheus targets are `UP`
* Test queries directly in Prometheus
* Test Grafana data source connection

### Missing App Metrics

```bash
curl http://localhost:3001/metrics
```

* Install `prom-client` in Node.js: `npm install prom-client`

### AlertManager Issues

```bash
docker-compose logs alertmanager
```

* Verify alert rules in Prometheus dashboard

---

## Best Practices

* Clear dashboard titles & consistent colors
* Alert only on meaningful thresholds
* Use "Golden Signals": latency, traffic, errors, saturation

---

## Production Considerations

**Security**

* Change default passwords
* Use HTTPS
* Restrict network access

**Scalability**

* Use external Prometheus storage or Thanos
* Use federated Prometheus for large-scale setups

**Reliability**

* Monitor Prometheus & Grafana uptime
* Back up dashboards/configs
* Use redundancy & alerting for failures

---

## 🧹 Clean Up

```bash
docker-compose down
docker-compose down -v
docker image prune
```

---

## ✅ What You Learned

* Monitoring setup with Prometheus + Grafana
* System, container, and app-level metrics
* Dashboard creation & customization
* Alerts via AlertManager
* AWS/Kubernetes integration

---

## 📈 Real-World Applications

* SRE monitoring of SLIs/SLOs
* Incident troubleshooting
* Performance bottleneck detection
* Capacity planning
* DevOps observability workflows

---

## ⏭️ Next Steps

* Add custom metrics to your apps
* Set up logging with ELK
* Add tracing with Jaeger
* Explore SLI/SLOs
* Move on to **Project 5: Multi-Environment Setup**

🎉 Congratulations! You now have professional-grade monitoring!
