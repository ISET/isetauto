import tensorflow as tf

FLAGS = tf.app.flags.FLAGS

tf.app.flags.DEFINE_integer("batchSize", 2, """Number of images to process in a batch""")
tf.app.flags.DEFINE_integer("numEpochsPerDecay", 300, """Number of epochs per batch""")
tf.app.flags.DEFINE_float("initialLearningRate", 0.0001, """Initial learning rate""")
tf.app.flags.DEFINE_float("learningRateDecay", 0.1, """Learning rate decay.""")
tf.app.flags.DEFINE_float("momentum", 0.9, """Momentum of the gradient descent algorithm.""")
tf.app.flags.DEFINE_integer("nGpus", 8,"""Number of GPU cards.""")
tf.app.flags.DEFINE_integer("maxSteps", 200000, "Number of batches to run.")
tf.app.flags.DEFINE_string("logDir",'./logDirTrain/',"""Directory where training log data is stored.""")
tf.app.flags.DEFINE_string("networkArchitecture", "UNetSmallDepth", """Define the Deep Network architecture.""")
tf.app.flags.DEFINE_string("dataset", "LightfieldSmallDepth", """Define the Deep Network architecture.""")
tf.app.flags.DEFINE_float("keepProb", 1.0, """Dropout parameter.""")
tf.app.flags.DEFINE_float("weightDecay", 0.0001, """Weight penalty tuning parameter.""")



class Solver:

    def __init__(self, network, dataset):
        self.network = network
        self.dataset = dataset



    def train(self):

        numBatchesPerEpoch = 100
        decaySteps = int(numBatchesPerEpoch * FLAGS.numEpochsPerDecay)

        globalStep = tf.get_variable('globalStep', [], initializer=tf.constant_initializer(0), trainable=False)
        learningRate = tf.train.exponential_decay(FLAGS.initialLearningRate, globalStep, decaySteps,
                                                      FLAGS.learningRateDecay, staircase=True)

        opt = tf.train.MomentumOptimizer(learningRate, FLAGS.momentum)

        reg = tf.placeholder(tf.float32, name='Regularization')
        keepProb = tf.placeholder(tf.float32, name='keepProb')
        isTraining = tf.placeholder(tf.int8, name='isTraining')



        # images, labels = self.dataset.distorted_inputs(FLAGS.dataDir, FLAGS.batchSize, provideDepth=True)

        images = tf.placeholder(tf.float32,shape=(48,448,448,3))
        labels = tf.placeholder(tf.float32)

        self.network.loss(images, labels, 0.01)

        init = tf.initialize_all_variables()
        summaryOp = tf.merge_all_summaries()
        saver = tf.train.Saver(tf.all_variables())

        sess = tf.Session(config=tf.ConfigProto(allow_soft_placement=True))
        sess.run(init)

        tf.train.start_queue_runners(sess=sess)
        summaryWriter = tf.train.SummaryWriter(FLAGS.logDir, sess.graph)

        feedDict = {reg: FLAGS.weightDecay, keepProb: FLAGS.keepProb, isTraining: 1}

        for step in xrange(FLAGS.maxSteps):

            startTime = time.time()
            lossVal, accyVal, _ = sess.run([meanLoss, meanAccy, emaOp], feed_dict=feedDict)
            duration = time.time() - startTime

            if step % 10 == 0:
                    numExamplesPerStep = FLAGS.batchSize * FLAGS.nGpus
                    examplesPerSec = numExamplesPerStep / duration
                    secPerBatch = duration / FLAGS.nGpus
                    epoch = numExamplesPerStep * step / dataset.NUM_EXAMPLES_PER_EPOCH_FOR_TRAIN

                    formatStr = ('%s: step %d, epoch %d, loss = %.2f, accy = %.2f (%.1f examples/sec; %.3f sec/batch)')
                    print formatStr % (datetime.now(), step, epoch, lossVal, accyVal, examplesPerSec, secPerBatch)

            if step % 100 == 0:
                    summaryStr = sess.run(summaryOp, feed_dict=feedDict)
                    summaryWriter.add_summary(summaryStr, step)

            if step % 1000 == 0:
                    chkptPath = os.path.join(FLAGS.logDir, 'model.ckpt')
                    saver.save(sess, chkptPath, global_step=step)

        sess.close()