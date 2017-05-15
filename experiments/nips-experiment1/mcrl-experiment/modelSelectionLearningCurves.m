function [BICs,models,RSS,DF]=modelSelectionLearningCurves(X,y)
    model = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2+b5*x3+b6*x2*x3))',[0.01;0.01;0.25;0.2;0.2;0.2])
    BIC_full=model.ModelCriterion.BIC;
    RSS_full=sum(model.Residuals.Raw.^2);
    DF_full=model.DFE;
    
    model_restricted1 = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2+b5*x3))',[0.01;0.01;0.25;0.2;0.2])
    BIC_restricted(1)=model_restricted1.ModelCriterion.BIC;
    RSS_restricted1=sum(model_restricted1.Residuals.Raw.^2);
    DF_restricted1=model_restricted1.DFE;
    
    model_restricted2 = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2+0*x3))',[0.01;0.01;0.25;0.2])
    BIC_restricted(2)=model_restricted2.ModelCriterion.BIC;
    RSS_restricted2=sum(model_restricted2.Residuals.Raw.^2);
    DF_restricted2=model_restricted2.DFE;
    
    
    model_restricted3 = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+0*x2+b4*x3))',[0.01;0.01;0.25;0.2])
    BIC_restricted(3)=model_restricted3.ModelCriterion.BIC;
    RSS_restricted3=sum(model_restricted3.Residuals.Raw.^2);
    DF_restricted3=model_restricted3.DFE;

    model_restricted4 = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+0*x2+0*x3))',[0.01;0.01;0.25])
    BIC_restricted(4)=model_restricted4.ModelCriterion.BIC;
    RSS_restricted4=sum(model_restricted4.Residuals.Raw.^2);
    DF_restricted4=model_restricted4.DFE;    
    
    model_restricted5 = fitnlm(X,y(:),'y ~ (1-b1)*sigmoid(b2+x1*(b3+b4*x2+b4*x3))',[0.01;0.01;0.25;0.2])
    BIC_restricted(5)=model_restricted5.ModelCriterion.BIC;
    RSS_restricted5=sum(model_restricted5.Residuals.Raw.^2);
    DF_restricted5=model_restricted5.DFE;    
    
    BICs=[BIC_full,BIC_restricted];
    models={model,model_restricted1,model_restricted2,model_restricted3,...
        model_restricted4,model_restricted5};
    RSS=[RSS_full,RSS_restricted1,RSS_restricted2,RSS_restricted3,...
        RSS_restricted4,RSS_restricted5];
    DF=[DF_full,DF_restricted1,DF_restricted2,DF_restricted3,...
        DF_restricted4,DF_restricted5];
end