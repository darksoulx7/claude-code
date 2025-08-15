# Start Payroll Project

Starts payroll project development environment:
1. Frontend server: runs `npm start` in background from `/home/harshank/repos/payroll`
2. Backend server: runs `npm run local` in background from `/home/harshank/repos/payroll/backend`  

```bash
cd /home/harshank/repos/payroll && npm start > /tmp/payroll-frontend.log 2>&1 & \
cd /home/harshank/repos/payroll/backend && npm run local > /tmp/payroll-backend.log 2>&1 & \
```