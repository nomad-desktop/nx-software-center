//
// Created by alexis on 7/31/18.
//

#ifndef NX_SOFTWARE_CENTER_UPGRADETASK_H
#define NX_SOFTWARE_CENTER_UPGRADETASK_H

#include "Task.h"
#include "Deployer.h"
#include "tasks/DeployTask.h"
#include "Remover.h"
#include "tasks/RemoveTask.h"

class UpgradeTask : public Task {
    Q_OBJECT
    QString appId;

    Deployer *deployer;
    Remover *remover;

    DeployTask *deployTask;
    RemoveTask *removeTask;
    DeployedApplicationsRegistry * deployedApplicationsRegistry;
public:
    explicit UpgradeTask(QObject *parent = nullptr);

    void setAppId(const QString &appId);

    void setDeployer(Deployer *deployer);

    void setRemover(Remover *remover);

    void setDeployedApplicationsRegistry(DeployedApplicationsRegistry *deployedApplicationsRegistry);

    void start() override;

    void stop() override;

protected slots:
    void handleDeployCompleted();
    void handleDeployFailed();
    void handleRemoveCompleted();
    void handleRemoveFailed();
    void handleTaskChanged();

private:
    void deployNewAppImage();

    void removeOldAppImage();

    void disposeDeployTask();

    void disposeRemoveTask();
};


#endif //NX_SOFTWARE_CENTER_UPGRADETASK_H
