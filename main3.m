clear all; close all;
global w CaseCBRTraining;
step=0.1;
alpha=0.4
pourcentageTest=0.25;
%for alpha=0.1:step:0.9
    clear Similarities
    clear Similarities2
    clear CaseCBR2
    clear CaseSim
    clear mat
%%
%%Data loading
    [CaseCBR, Casestxt, Casestab] = xlsread('Data2015to2017.xlsx');
    columnSize=length(CaseCBR(1,:));
    lineSize=length(CaseCBR(:,1));
    n=columnSize-1; %% number of attributes
    nbreTest=pourcentageTest*lineSize;
    CaseCBRTest=CaseCBR(1:nbreTest,:);
    CaseCBRTestPrime=CaseCBR(1:nbreTest,1:n);
    CaseCBRTraining=CaseCBR(nbreTest+1:lineSize,:);
    SolutionExpected=CaseCBRTest(1:nbreTest, columnSize);
    
    %
    %Construct the pairwise comparison matrix.
    w=WeightFct();
    %%
    %New case entry
    %ik=4
    
    RESULTS{1,1}='Cases';
    RESULTS{1,2}='Expected Solution';
    RESULTS{1,3}='Reuse Solution';
    RESULTS{1,4}='Revise Solution';
    RESULTS{1,5}='Reuse Accuracy';
    RESULTS{1,6}='Revise Accuracy';
    RESULTS{1,7}='PS0 Reuse Solution';
    RESULTS{1,8}='PS0 Reuse Accuracy';
    RESULTS{1,9}='TestSeuil';
    RESULTS{1,10}='SolMoyenne';
    RESULTS{1,11}='Solution Finale';
    RESULTS{1,12}='Ecart Solution Finale';
    %%
    %pso solution obtention
 pso %obtention des coefficient w: BestSol
    %%
    %Revise
    [line, column] = size(CaseCBRTraining);
    Training=CaseCBRTraining(1:line,1:n);
    Target= CaseCBRTraining(1:line,column);
    abcisse=grapheAbcisse(SolutionExpected,nbreTest); %1:1:nbreTest
    Results3=ReviseFct3(Training,Target,CaseCBRTestPrime)
    
   
    %
    
    for ik=1:nbreTest
    %for ik=1:30
        QueryCase=CaseCBRTest(ik,1:n);
        [SolutionModel MoySolSim]=ModelCBR(CaseCBRTraining, QueryCase, Casestab);
        %SolutionRevise=ReviseFct2(QueryCase);
        SolutionRevise=Results3(ik);
        disp(['Results: case' num2str(ik)]);
        ExpectedSolution=CaseCBRTest(ik,n+1)
        %SolutionModel
        accuracyModel=abs(ExpectedSolution-SolutionModel)
        %SolutionRevise
        accuracyRevise=abs(ExpectedSolution-SolutionRevise)
        RESULTS{ik+1,1}=['Cases' num2str(ik)];
        RESULTS{ik+1,2}=ExpectedSolution;
        RESULTS{ik+1,3}= SolutionModel;
        RESULTS{ik+1,4}=SolutionRevise;
        RESULTS{ik+1,5}=accuracyModel;
        RESULTS{ik+1,6}=accuracyRevise;
        PredictedReuse(ik)=SolutionModel;
        PredictedRevise(ik)=SolutionRevise;
        SolutionExpected(ik)=ExpectedSolution;
        %Pso solution
        PsoSolution=sum(QueryCase.*BestSol.Position);
        accuracyPsoSolution=abs(ExpectedSolution-PsoSolution)
        RESULTS{ik+1,7}=PsoSolution;
        RESULTS{ik+1,8}=accuracyPsoSolution;
        %TestSeuil
        RESULTS{ik+1,9}=abs(mean([SolutionModel  PsoSolution])-MoySolSim)/mean([SolutionModel  PsoSolution]);
        %RESULTS{ik+1,9}=abs(MoySolSim-SolutionModel)/SolutionModel;
         RESULTS{ik+1,10}=mean([SolutionModel  PsoSolution]);
         %%
         %vecteur des solutions du Reuse: Moyenne entre SolCopy (SolutionModel) et PsoSol
        SolReuseVect(ik)=mean([SolutionModel  PsoSolution]);
        SolutionReviseVect(ik)=SolutionRevise;
        %        TestSeuilVect(ik)=abs(mean([SolutionModel  PsoSolution])-MoySolSim)/mean([SolutionModel  PsoSolution]);
        TestSeuilVect(ik)=abs(PsoSolution-MoySolSim)/PsoSolution;
        PsoSolutionVect(ik)=PsoSolution;
        
         
    end
    TestSeuilVect=TestSeuilVect';
    SolutionReviseVect=SolutionReviseVect';
    SolReuseVect=SolReuseVect';
    
    PredictedReuse=PredictedReuse';  %     copy
    PsoSolutionVect=PsoSolutionVect';
    save('RESULTATSComparatifs.mat','RESULTS')
%%
%Synthese
    SYNTHESE{1,1}='Beta';
%     SYNTHESE{1,2}='EXPECTED SOLUTION';
%     SYNTHESE{1,3}='FINAL SOLUTION';   
%     SYNTHESE{1,4}='ECART';
    SYNTHESE{1,2}='MAE';
    SYNTHESE{1,3}='RSME';
    ii=1
%Beta
a=min(TestSeuilVect);b=max(TestSeuilVect);
nbreBeta=10;
LePas=(b-a)/nbreBeta;
jj=1;
beta=a;
% for beta=a:LePas:b
    clear SolFinale
        for ik=1:nbreTest
            if(TestSeuilVect(ik)>beta)
                SolFinale(ik)=Results3(ik);
            else
%                 SolFinale(ik)=SolReuseVect(ik);
                SolFinale(ik)=PsoSolutionVect(ik);
            end

            RESULTS{ik+1,11}=SolFinale(ik);
            RESULTS{ik+1,12}=abs(ExpectedSolution-SolFinale(ik));
        end
%          rmseGaussianRegression = rmse(SolutionExpected, SolFinale)
%          accuracyRmseGaussian = abs(100 - rmseGaussianRegression)
%          
%          maeSVMRegression=mae(SolutionExpected-SolFinale)
%          accuracySVMRegressionMae = abs(100 - maeSVMRegression)
SolFinale=SolFinale';
         rSquare= RSquare(SolutionExpected, SolFinale)
        ff=figure;
      plot(abcisse,SolFinale, 'o-r', abcisse, SolutionExpected, '*-b'); 
      xlabel('Index'); 
      ylabel('System Load');
      title(['FINAL SOLUTION: Beta=' num2str(beta) '; ACCURACY=' num2str(rSquare*100) '%']);
      legend('Solution forecasted','Solution expected');
      %error4= errorElements(SolutionExpected,Results3,nbreTest);
      filename=['SolutionFinale/F' num2str(jj)];
      saveas(ff,filename,'png');
      %
      jj=jj+1;
      
              %
              
        SYNTHESE{ii+1,1}=beta;
%         SYNTHESE{ii+1,2}=accuracySVMRegressionMae;
%         SYNTHESE{ii+1,3}=accuracyRmseGaussian;
        ii=ii+1;
         
        

% end
   
%%
%Graphe du Reuse
%  rmseGaussianRegression = rmse(SolutionExpected, SolReuseVect)
%  accuracyRmseGaussian = abs(100 - rmseGaussianRegression)
         
%  maeSVMRegression=mae(SolutionExpected-SolReuseVect)
%  accuracySVMRegressionMae = abs(100 - maeSVMRegression)
%  SolReuseVect=SolReuseVect';


% % % % %  rSquare= RSquare(SolutionExpected, SolReuseVect)
% % % % %         ff=figure;
% % % % %       plot(abcisse,SolReuseVect, 'o-r', abcisse, SolutionExpected, '*-b'); 
% % % % %       xlabel('Index'); 
% % % % %       ylabel('System Load');
% % % % %       title(['MEAN(SOLUTION COPY,PSO SOLUTION): RSQUARE=' num2str(rSquare)]);
% % % % %       legend('Solution Reuse','Solution expected');
% % % % %       %error4= errorElements(SolutionExpected,Results3,nbreTest);
% % % % %       filename=['SolutionReuse/F' num2str(jj)];
% % % % %       saveas(ff,filename,'png');
% % % % %       


 %%
 %Graphe du Revise
%  rmseGaussianRegression = rmse(SolutionExpected, Results3)
%  accuracyRmseGaussian = abs(100 - rmseGaussianRegression)
         
%  maeSVMRegression=mae(SolutionExpected-Results3)
%  accuracySVMRegressionMae = abs(100 - maeSVMRegression)
       rSquare= RSquare(SolutionExpected, Results3)
        ff=figure;
      plot(abcisse,Results3, 'o-r', abcisse, SolutionExpected, '*-b'); 
      xlabel('Index'); 
      ylabel('System Load');
      title(['REVISE: ACCURACY=' num2str(rSquare*100) '%']);
      legend('Solution Revise','Solution expected');
      %error4= errorElements(SolutionExpected,Results3,nbreTest);
      filename=['SolutionRevise/F' num2str(jj)];
      saveas(ff,filename,'png');
%     %With Cross Validation
%     CVMdl4 = crossval(Mdl4)
%     %[Results4] = predict(CVMdl4,CaseCBRTestPrime)
  
% %         

% % % % % % rSquare= RSquare(SolutionExpected, PredictedReuse)
% % % % % %         ff=figure;
% % % % % %       plot(abcisse,PredictedReuse, 'o-r', abcisse, SolutionExpected, '*-b'); 
% % % % % %       xlabel('Index'); 
% % % % % %       ylabel('System Load');
% % % % % %       title(['SOLUTION COPY: RSQUARE=' num2str(rSquare)]);
% % % % % %       legend('Solution Copy','Solution expected');
% % % % % %       %error4= errorElements(SolutionExpected,Results3,nbreTest);
% % % % % %       filename=['FF' num2str(jj)];
% % % % % %       saveas(ff,filename,'png');

      rSquare= RSquare(SolutionExpected, PsoSolutionVect)
        ff=figure;
      plot(abcisse,PsoSolutionVect, 'o-r', abcisse, SolutionExpected, '*-b'); 
      xlabel('Index'); 
      ylabel('System Load');
      title(['PSO REUSE SOLUTION : ACCURACY=' num2str(rSquare*100) '%']);
      legend('Pso Reuse Solution ','Solution expected');
      %error4= errorElements(SolutionExpected,Results3,nbreTest);
      filename=['F' num2str(jj)];
      saveas(ff,filename,'png');



    